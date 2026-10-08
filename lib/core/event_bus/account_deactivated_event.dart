/// Fired when the backend reports the student's account is no longer active
/// (`ACCOUNT_INACTIVE` — deactivated by an admin, or auto-locked after a
/// foreign-device login).
///
/// Policy: the moment this is known, every downloaded lesson is deleted from
/// the device — offline copies must not outlive the right to watch them. It is
/// deliberately separate from [SessionExpiredEvent]: an ordinary expired
/// session (the 7-day refresh token ran out) logs the student out but keeps
/// their downloads, since they are still a paying student.
class AccountDeactivatedEvent {
  const AccountDeactivatedEvent();
}
