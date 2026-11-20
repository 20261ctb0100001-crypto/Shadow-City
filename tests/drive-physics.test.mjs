import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

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
  assert.ok(next.speed <= 33.3, 'truck must stay below 120 km/h');
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
