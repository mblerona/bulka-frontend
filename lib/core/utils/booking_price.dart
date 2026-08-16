/// Temporary local service-fee rule for the Tourist booking flow — 7.5%
/// of the accommodation subtotal (nightly price × nights), rounded to the
/// nearest whole denar. No real backend pricing/business rule exists yet;
/// this is the one place the rate lives, isolated so a real backend-driven
/// fee calculation can replace it later without touching
/// `ReservationController`/`BookingRequestScreen`/the confirmation screen.
///
/// TODO: replace with a real backend/business pricing rule once one
/// exists — the current 7.5% flat rate is a placeholder, not a quoted
/// business decision.
const double bookingServiceFeeRate = 0.075;

double calculateServiceFee(double subtotal) =>
    (subtotal * bookingServiceFeeRate).roundToDouble();
