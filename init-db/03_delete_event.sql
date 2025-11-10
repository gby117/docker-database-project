
CREATE OR REPLACE FUNCTION gp_delete_event(p_event_id INT, p_actor_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_owner_id   INT;
  v_actor_role VARCHAR(20);
  v_title      TEXT;
  v_status     VARCHAR(20);
BEGIN
  -- Ensure event exists; grab owner, title, status
  SELECT organizer_id, title, status
    INTO v_owner_id, v_title, v_status
  FROM events
  WHERE event_id = p_event_id;

  IF v_owner_id IS NULL THEN
    RAISE EXCEPTION 'Event % not found', p_event_id;
  END IF;

  -- Ensure actor exists; get role
  SELECT role INTO v_actor_role
  FROM users
  WHERE user_id = p_actor_id;

  IF v_actor_role IS NULL THEN
    RAISE EXCEPTION 'Actor % not found', p_actor_id;
  END IF;

  -- Permission: organizer or admin (case-insensitive)
  IF NOT (p_actor_id = v_owner_id OR LOWER(v_actor_role) = 'admin') THEN
    RAISE EXCEPTION 'Permission denied for user % to delete event %', p_actor_id, p_event_id;
  END IF;

  -- Already canceled?
  IF LOWER(v_status) = 'canceled' THEN
    RETURN 'Already canceled';
  END IF;

  -- Soft delete: mark event as canceled
  UPDATE events
  SET status = 'canceled'
  WHERE event_id = p_event_id;

  -- Remove registrations for this event
  DELETE FROM registrations
  WHERE event_id = p_event_id;

  RETURN 'Event canceled and registrations removed';
END;
$$;
