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
  assert.ok(html.includes('marker.position.set(roadCenter(-29400)+7,0,-29400)'));
  assert.ok(html.includes('station.position.set(roadCenter(-3000)+27,0,-3000)'));
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
  assert.ok(html.includes('const isMobileDevice='));
  assert.ok(html.includes('if(isMobileDevice){'));
  assert.ok(html.includes("screen.orientation.lock('landscape-primary')"));
});

test('delivery mission text matches the coastal destination marker', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('Leve a carga até o terminal no litoral.'));
  assert.ok(!html.includes('Leve a carga até o posto marcado.'));
});

test('Pages deployment waits for artifact metadata propagation', async () => {
  const workflow = await readFile(new URL('../.github/workflows/deploy-pages.yml', import.meta.url), 'utf8');
  assert.ok(workflow.includes('name: Wait for Pages artifact metadata'));
  assert.ok(workflow.includes('run: sleep 10'));
});

test('all four cities have a large connected street grid and dense blocks', async () => {
  const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
  assert.ok(html.includes('const cityLength=1680'));
  assert.ok(html.includes('parallelOffsets=[48,132,216,300,384]'));
  assert.ok(html.includes('for(let row=0;row<13;row++)'));
  assert.ok(html.includes('for(let band=0;band<4;band++)for(let row=0;row<12;row++)'));
  assert.ok(html.includes('new THREE.InstancedMesh(windowGeo,glassCity,18000)'));
  for (const city of ["buildCity('Ponta Grossa'", "buildCity('Curitiba'", "buildCity('Florianópolis'", "buildCity('Santos'"]) {
    assert.ok(html.includes(city), city + ' must use the expanded city builder');
  }
});
