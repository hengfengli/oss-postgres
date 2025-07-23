---START---
--
-- ASYNC
--

--Should work. Send a valid message via a valid channel name
SELECT pg_notify('notify_async1','sample message1');
---END---
---START---
SELECT pg_notify('notify_async1','');
---END---
---START---
SELECT pg_notify('notify_async1',NULL);
---END---
---START---

-- Should fail. Send a valid message via an invalid channel name
SELECT pg_notify('','sample message1');
---END---
---START---
SELECT pg_notify(NULL,'sample message1');
---END---
---START---
SELECT pg_notify('notify_async_channel_name_too_long______________________________','sample_message1');
---END---
---START---

--Should work. Valid NOTIFY/LISTEN/UNLISTEN commands
NOTIFY notify_async2;
---END---
---START---
LISTEN notify_async2;
---END---
---START---
UNLISTEN notify_async2;
---END---
---START---
UNLISTEN *;
---END---
---START---

-- Should return zero while there are no pending notifications.
-- src/test/isolation/specs/async-notify.spec tests for actual usage.
SELECT pg_notification_queue_usage();
---END---
