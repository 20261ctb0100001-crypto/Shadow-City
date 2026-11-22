import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const physicsUrl = new URL('../scripts/drive-physics.js', import.meta.url);
async function loadPhysics() {
  assert.ok(existsSync(fileURLToPath(physicsUrl)), 'scripts/drive-physics.js must exist');
  return import(physicsUrl.href);
}

test('drive physics accelerates a loaded truck and respects the speed cap', async () => {
  const { stepTruckPhysics } = await loadPhysics();
  const next = stepTruckPhysics(
    { speed: 0, heading: 0 },
    { throttle: 1, brake: 0, turn: 0, gear: 'D', dt: 1, offRoad: false }
  );
  assert.ok(next.speed > 0, 'accelerator must increase speed');
  assert.ok(next.speed <= 41.7, 'truck must stay below 150 km/h');
});


test('urban speed limit allows trucks up to 80 km/h', async () => {
  const { stepTruckPhysics } = await loadPhysics();
  const next = stepTruckPhysics(
    { speed: 12, heading: 0 },
    { throttle: 1, brake: 0, turn: 0, gear: 'D', dt: 0.1, offRoad: false, speedLimit: 22.2 }
  );
  assert.ok(next.speed <= 22.2, 'urban speed must respect the 80 km/h truck limit');
});

test('brake reduces forward speed without reversing the truck', async () => {
  const { stepTruckPhysics } = await loadPhysics();
  const next = stepTruckPhysics(
    { speed: 15, heading: 0 },
    { throttle: 0, brake: 1, turn: 0, gear: 'D', dt: 1, offRoad: false }
  );
  assert.ok(next.speed >= 0 && next.speed < 15, 'braking must slow down without reversing');
});

test('left and right steering change the truck heading in opposite directions', async () => {
  const { stepTruckPhysics } = await loadPhysics();
  const base = { speed: 18, heading: 0 };
  const common = { throttle: 0, brake: 0, gear: 'D', dt: 0.5, offRoad: false };
  const left = stepTruckPhysics(base, { ...common, turn: -1 });
  const right = stepTruckPhysics(base, { ...common, turn: 1 });
  assert.notEqual(left.heading, 0);
  assert.notEqual(right.heading, 0);
  assert.ok(left.heading * right.heading < 0, 'left and right must turn opposite ways');
});

test('off-road driving loses speed faster than normal coasting', async () => {
  const { stepTruckPhysics } = await loadPhysics();
  const state = { speed: 20, heading: 0 };
  const common = { throttle: 0, brake: 0, turn: 0, gear: 'D', dt: 1 };
  const road = stepTruckPhysics(state, { ...common, offRoad: false });
  const dirt = stepTruckPhysics(state, { ...common, offRoad: true });
  assert.ok(dirt.speed < road.speed, 'dirt must have stronger rolling resistance');
});

test('minimap is a live canvas, not a static CSS road decoration', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.match(html, /id="minimapCanvas"/);
  assert.match(html, /function drawMinimap/);
  assert.doesNotMatch(html, /#minimap:before/);
  assert.doesNotMatch(html, /#minimap:after/);
});

test('published site copies the runtime physics module', async () => {
  const workflow = await readFile(new URL('../.github/workflows/deploy-pages.yml', import.meta.url), 'utf8');
  assert.match(workflow, /cp -R scripts build\/scripts/);
  assert.match(workflow, /test -s build\/scripts\/drive-physics\.js/);
});

test('the main Three.js module has valid JavaScript syntax', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  const scriptStart = html.indexOf('<script type="module">');
  assert.ok(scriptStart >= 0, 'main module script must exist');
  const contentStart = scriptStart + '<script type="module">'.length;
  const scriptEnd = html.indexOf('</script>', contentStart);
  assert.ok(scriptEnd > contentStart, 'main module script must close');
  const moduleSource = html.slice(contentStart, scriptEnd);
  const checked = spawnSync(process.execPath, ['--check', '--input-type=module'], {
    input: moduleSource, encoding: 'utf8'
  });
  assert.equal(checked.status, 0, checked.stderr || checked.stdout || 'module syntax check failed');
});

test('delivery and refueling targets are ahead on the negative-Z route', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('marker.position.set(roadCenter(-64400)+7,0,-64400)'));
  assert.ok(html.includes('station.position.set(roadCenter(-10000)+27,0,-10000)'));
});

test('all four Brazilian city stops remain in the route', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  for (const city of ['Ponta Grossa', 'Curitiba', 'Florianópolis', 'Santos']) {
    assert.ok(html.includes(city), city + ' must remain on the route');
  }
});

test('3D canvas is layered above the page background', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes("renderer.domElement.style.zIndex='1'"));
  assert.ok(html.includes('z-index:1!important;pointer-events:none'));
});

test('Ponta Grossa has a visible entrance landmark near the start', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('PONTA GROSSA'));
  assert.ok(html.includes('cityGate.position.set(cx,0,centerZ+160)'));
});

test('fullscreen and landscape locking are limited to mobile devices', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('const mobile='));
  assert.ok(html.includes('if(mobile){'));
  assert.ok(html.includes("screen.orientation.lock('landscape-primary')"));
});

test('mission banner is removed and the four-city map opens from the minimap', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.doesNotMatch(html, /id="mission"/);
  assert.ok(html.includes('id="minimap"'));
  assert.ok(html.includes('id="cityMapOverlay"'));
  assert.ok(html.includes('id="fullRouteMap"'));
  assert.ok(html.includes("document.getElementById('minimap').addEventListener('click',openCityMap)"));
  for (const city of ['Ponta Grossa', 'Curitiba', 'Florianópolis', 'Santos']) assert.ok(html.includes(city));
});

test('steering uses a draggable virtual wheel and no directional arrow pad', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('id="steeringWheel"'));
  assert.ok(html.includes("steeringWheel.addEventListener('pointermove'"));
  assert.doesNotMatch(html, /id="dpad"/);
});

test('truck has a higher acceleration and top speed after the update', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('vehicleIsCar?30.5:30.5') === false);
  assert.ok(html.includes('vehicleIsCar?27.8:30.5'));
  assert.ok(html.includes('vehicleIsCar?55.6:50'));
  assert.ok(html.includes('acceleration:vehicleIsCar?14:16'));
});

test('Pages deployment waits for artifact metadata propagation', async () => {
  const workflow = await readFile(new URL('../.github/workflows/deploy-pages.yml', import.meta.url), 'utf8');
  assert.ok(workflow.includes('name: Wait for Pages artifact metadata'));
  assert.ok(workflow.includes('run: sleep 10'));
});

test('all four cities have a large connected street grid and dense blocks', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('const cityLength=8000'));
  assert.ok(html.includes('parallelOffsets=[48,132,216]'));
  assert.ok(html.includes('for(let row=0;row<61;row++)'));
  assert.ok(html.includes('for(let band=0;band<2;band++)for(let row=0;row<60;row++)'));
  assert.ok(html.includes('steps=13000,startZ=-65000,endZ=700'));
  assert.ok(html.includes('speedLimit:inCity?(vehicleIsCar?27.8:22.2):(vehicleIsCar?55.6:41.7)'));
  assert.ok(html.includes('vehicleMixer.update(dt)'));
  assert.ok(html.includes('window.prepareSelectedVehicle=async function(id)'));
  assert.ok(html.includes('function makeTrafficTruck'));
  assert.ok(html.includes('for(let i=0;i<8;i++)makeTrafficTruck'));
  assert.ok(html.includes('new THREE.InstancedMesh(windowGeo,glassCity,18000)'));
  for (const city of ["buildCity('Ponta Grossa'", "buildCity('Curitiba'", "buildCity('Florianópolis'", "buildCity('Santos'"]) {
    assert.ok(html.includes(city), city + ' must use the expanded city builder');
  }
});


test('garage offers 25 cars and 25 trucks with matching 3D preview images', async () => {
  const catalog = await readFile(new URL('../scripts/vehicle-catalog.js', import.meta.url), 'utf8');
  assert.equal((catalog.match(/"id":"truck-/g) || []).length, 25, 'must list 25 trucks');
  assert.equal((catalog.match(/"id":"car-/g) || []).length, 25, 'must list 25 cars');
  assert.equal((catalog.match(/"model":/g) || []).length, 50, 'every vehicle must have a GLB model');
  assert.equal((catalog.match(/"image":/g) || []).length, 50, 'every vehicle must have a matching preview render');
});

test('selected GLB model replaces the procedural player vehicle and uses car or truck handling', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('three/addons/loaders/GLTFLoader.js'));
  assert.ok(html.includes('playerModelGroup.add(model)'));
  assert.ok(html.includes('vehicleIsCar?55.6:41.7'));
  assert.ok(html.includes('acceleration:vehicleIsCar?14:11.5'));
  assert.ok(html.includes('brakeForce:vehicleIsCar?13:12'));
});

test('house blocks include roofs, framed windows, garages and porches', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('new THREE.ConeGeometry(Math.max(width,depth)*.72,3.8,4)'));
  assert.ok(html.includes('windowFrames=new THREE.InstancedMesh'));
  assert.ok(html.includes('garageDoors=new THREE.InstancedMesh'));
  assert.ok(html.includes('const canopy=new THREE.Mesh'));
});

test('car physics is quicker than truck physics while retaining separate speed limits', async () => {
  const { stepTruckPhysics } = await loadPhysics();
  const state = { speed: 0, heading: 0 };
  const common = { throttle: 1, brake: 0, turn: 0, gear: 'D', dt: 0.1, offRoad: false };
  const truck = stepTruckPhysics(state, { ...common, acceleration: 6.5, speedLimit: 41.7 });
  const car = stepTruckPhysics(state, { ...common, acceleration: 9.5, speedLimit: 55.6 });
  assert.ok(car.speed > truck.speed);
  assert.ok(car.speed <= 55.6);
});


test('city neighborhoods place complete GLB house models in the street grid', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('const cityHousePlacements=[]'));
  assert.ok(html.includes('cityHouseModelUrls'));
  assert.ok(html.includes('loadCityHouseModels().then(()=>{renderer.render(scene,camera)})'));
  assert.ok(html.includes('housePool[(i+spot.style)%housePool.length].clone(true)'));
  assert.ok(html.includes('window.cityHouseModelsReady=true'));
});

test('selected vehicle GLB is rotated to match the simulator forward axis', async () => { const html = await readFile(new URL('../index.html', import.meta.url), 'utf8'); assert.ok(html.includes('model.rotation.y=Math.PI')); });
test('game becomes playable before optional neighborhood house assets finish downloading', async () => { const html = await readFile(new URL('../index.html', import.meta.url), 'utf8'); const ready=html.indexOf('window.gameReady=true'); const houses=html.indexOf('loadCityHouseModels().then'); assert.ok(ready>=0 && houses>ready); assert.ok(!html.includes('await loadCityHouseModels()')); });
