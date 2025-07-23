---START---
--
-- Test cases for COPY (INSERT/UPDATE/DELETE) TO
--
create sequence id_seq;
---END---
---START---
create table copydml_test (id int default nextval('id_seq'), t text);
---END---
---START---
insert into copydml_test (t) values ('a');
---END---
---START---
insert into copydml_test (t) values ('b');
---END---
---START---
insert into copydml_test (t) values ('c');
---END---
---START---
insert into copydml_test (t) values ('d');
---END---
---START---
insert into copydml_test (t) values ('e');
---END---
---START---

--
-- Test COPY (insert/update/delete ...)
--
copy (insert into copydml_test (t) values ('f') returning id) to stdout;
---END---
---START---
copy (update copydml_test set t = 'g' where t = 'f' returning id) to stdout;
---END---
---START---
copy (delete from copydml_test where t = 'g' returning id) to stdout;
---END---
---START---

--
-- Test \copy (insert/update/delete ...)
--
\copy (insert into copydml_test (t) values ('f') returning id) to stdout;
---END---
---START---
\copy (update copydml_test set t = 'g' where t = 'f' returning id) to stdout;
---END---
---START---
\copy (delete from copydml_test where t = 'g' returning id) to stdout;
---END---
---START---

-- Error cases
copy (insert into copydml_test default values) to stdout;
---END---
---START---
copy (update copydml_test set t = 'g') to stdout;
---END---
---START---
copy (delete from copydml_test) to stdout;
---END---
---START---

create rule qqq as on insert to copydml_test do instead nothing;
---END---
---START---
copy (insert into copydml_test default values) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on insert to copydml_test do also delete from copydml_test;
---END---
---START---
copy (insert into copydml_test default values) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on insert to copydml_test do instead (delete from copydml_test; delete from copydml_test);
---END---
---START---
copy (insert into copydml_test default values) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on insert to copydml_test where new.t <> 'f' do instead delete from copydml_test;
---END---
---START---
copy (insert into copydml_test default values) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---

create rule qqq as on update to copydml_test do instead nothing;
---END---
---START---
copy (update copydml_test set t = 'f') to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on update to copydml_test do also delete from copydml_test;
---END---
---START---
copy (update copydml_test set t = 'f') to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on update to copydml_test do instead (delete from copydml_test; delete from copydml_test);
---END---
---START---
copy (update copydml_test set t = 'f') to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on update to copydml_test where new.t <> 'f' do instead delete from copydml_test;
---END---
---START---
copy (update copydml_test set t = 'f') to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---

create rule qqq as on delete to copydml_test do instead nothing;
---END---
---START---
copy (delete from copydml_test) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on delete to copydml_test do also insert into copydml_test default values;
---END---
---START---
copy (delete from copydml_test) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on delete to copydml_test do instead (insert into copydml_test default values; insert into copydml_test default values);
---END---
---START---
copy (delete from copydml_test) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---
create rule qqq as on delete to copydml_test where old.t <> 'f' do instead insert into copydml_test default values;
---END---
---START---
copy (delete from copydml_test) to stdout;
---END---
---START---
drop rule qqq on copydml_test;
---END---
---START---

-- triggers
create function qqq_trig() returns trigger as $$
begin
if tg_op in ('INSERT', 'UPDATE') then
    raise notice '% % %', tg_when, tg_op, new.id;
---END---
---START---
    return new;
---END---
---START---
else
    raise notice '% % %', tg_when, tg_op, old.id;
---END---
---START---
    return old;
---END---
---START---
end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---
create trigger qqqbef before insert or update or delete on copydml_test
    for each row execute procedure qqq_trig();
---END---
---START---
create trigger qqqaf after insert or update or delete on copydml_test
    for each row execute procedure qqq_trig();
---END---
---START---

copy (insert into copydml_test (t) values ('f') returning id) to stdout;
---END---
---START---
copy (update copydml_test set t = 'g' where t = 'f' returning id) to stdout;
---END---
---START---
copy (delete from copydml_test where t = 'g' returning id) to stdout;
---END---
---START---

drop table copydml_test;
---END---
---START---
drop function qqq_trig();
---END---
