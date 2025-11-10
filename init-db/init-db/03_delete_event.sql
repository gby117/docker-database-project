-- GP-UC3: Delete Event with permission checks, attendee notifications, and audit log
CREATE OR REPLACE FUNCTION gp_delete_event(p_event_id INT, p_actor_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_owner_id INT;
  v_actor_role VARCHAR(20);
  v_event_title TEXT;
BEGIN
  -- find event + owner
  SELECT organizer_id, title INTO v_owner_id, v_event_title
  FROM events WHERE event_id = p_event_id;

  IF v_owner_id IS NULL THEN
    INSERT INTO audit_logs(actor_id, action, event_id, details)
    VALUES (p_actor_id, 'DELETE_DENIED', p_event_id, '{"reason":"EVENT_NOT_FOUND"}');
    RAISE EXCEPTION 'Event % not found', p_event_id;
  END IF;

  -- find actor role
  SELECT role INTO v_actor_role FROM users WHERE user_id = p_actor_id;
  IF v_actor_role IS NULL THEN
    INSERT INTO audit_logs(actor_id, action, event_id, details)
    VALUES (p_actor_id, 'DELETE_DENIED', p_event_id, '{"reason":"ACTOR_NOT_FOUND"}');
    RAISE EXCEPTION 'Actor % not found', p_actor_id;
  END IF;

  -- Organizer or ADMIN only
  IF NOT (p_actor_id = v_owner_id OR v_actor_role = 'ADMIN') THEN
    INSERT INTO audit_logs(actor_id, action, event_id, details)
    VALUES (p_actor_id, 'DELETE_DENIED', p_event_id, '{"reason":"PERMISSION_DENIED"}');
    RAISE EXCEPTION 'Permission denied for user % to delete event %', p_actor_id, p_event_id;
  END IF;

  -- already canceled?
  IF EXISTS (SELECT 1 FROM events WHERE event_id = p_event_id AND is_canceled) THEN
    INSERT INTO audit_logs(actor_id, action, event_id, details)
    VALUES (p_actor_id, 'DELETE_EVENT', p_event_id, '{"info":"ALREADY_CANCELED"}');
    RETURN 'Already canceled';
  END IF;

  -- soft delete (cancel)
  UPDATE events SET is_canceled = TRUE WHERE event_id = p_event_id;

  -- notify registered attendees
  INSERT INTO notifications (recipient_id, subject, body)
  SELECT r.attendee_id,
         'Event canceled: ' || v_event_title,
         'We''re sorry—"' || v_event_title || '" has been canceled.'
  FROM event_registrations r
  WHERE r.event_id = p_event_id;

  -- optional cleanup of registrations
  DELETE FROM event_registrations WHERE event_id = p_event_id;

  -- audit success
  INSERT INTO audit_logs(actor_id, action, event_id, details)
  VALUES (p_actor_id, 'DELETE_EVENT', p_event_id, '{"result":"CANCELED_AND_NOTIFIED"}');

  RETURN 'Event canceled and attendees notified';
END;
$$;
