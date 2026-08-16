/// Stand-in for a real signed-in Tourist identity — there is no auth/
/// session concept anywhere in this app yet. Every screen that needs "the
/// current Tourist" (booking creation, My Reservations' ownership filter)
/// shares this one constant so they always agree on who "I" is, instead of
/// each screen guessing its own value.
///
/// TODO: replace with the actual signed-in user's identity (and a real
/// tourist/user id on `Reservation`, not just a name match) once
/// authentication/backend integration exists.
const String mockTouristGuestName = 'Јована Јованова';
