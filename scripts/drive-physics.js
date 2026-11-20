export function stepTruckPhysics(state, input) {
  const dt = Math.max(0, Math.min(Number(input.dt) || 0, 0.1));
  let speed = Number(state.speed) || 0;
  let heading = Number(state.heading) || 0;
  const gear = input.gear || 'D';
  const throttle = Math.max(0, Math.min(1, Number(input.throttle) || 0));
  const brake = Math.max(0, Math.min(1, Number(input.brake) || 0));
  const turn = Math.max(-1, Math.min(1, Number(input.turn) || 0));
  const offRoad = Boolean(input.offRoad);
  const speedLimit = Math.max(5, Number(input.speedLimit) || 41.7);

  if (brake > 0) {
    const deceleration = (gear === 'R' ? 7.5 : 8.5) * brake * dt;
    speed = Math.sign(speed) * Math.max(0, Math.abs(speed) - deceleration);
  } else if (gear === 'D' && throttle > 0) {
    speed = Math.min(speedLimit, speed + 6.5 * throttle * dt);
  } else if (gear === 'R' && throttle > 0) {
    if (speed > 0) speed = Math.max(0, speed - 8 * throttle * dt);
    else speed = Math.max(-5.5, speed - 2.8 * throttle * dt);
  } else {
    const rollingResistance = offRoad ? 1.8 : 0.22;
    speed = Math.sign(speed) * Math.max(0, Math.abs(speed) - rollingResistance * dt);
  }

  const speedFactor = 0.25 + 0.75 * Math.min(Math.abs(speed) / 25, 1);
  const steeringRate = (offRoad ? 0.22 : 0.42) * speedFactor;
  const steeringDirection = gear === 'R' ? -1 : 1;
  heading -= turn * steeringDirection * steeringRate * dt;

  return {
    speed: Math.max(-5.5, Math.min(speedLimit, speed)),
    heading,
    dx: -Math.sin(heading) * speed * dt,
    dz: -Math.cos(heading) * speed * dt
  };
}
