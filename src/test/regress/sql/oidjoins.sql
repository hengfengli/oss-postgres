---START---
--
-- Verify system catalog foreign key relationships
--
DO $doblock$
declare
  fk record;
---END---
---START---
  nkeys integer;
---END---
---START---
  cmd text;
---END---
---START---
  err record;
---END---
---START---
begin
  for fk in select * from pg_get_catalog_foreign_keys()
  loop
    raise notice 'checking % % => % %',
      fk.fktable, fk.fkcols, fk.pktable, fk.pkcols;
---END---
---START---
    nkeys := array_length(fk.fkcols, 1);
---END---
---START---
    cmd := 'SELECT ctid';
---END---
---START---
    for i in 1 .. nkeys loop
      cmd := cmd || ', ' || quote_ident(fk.fkcols[i]);
---END---
---START---
    end loop;
---END---
---START---
    if fk.is_array then
      cmd := cmd || ' FROM (SELECT ctid';
---END---
---START---
      for i in 1 .. nkeys-1 loop
        cmd := cmd || ', ' || quote_ident(fk.fkcols[i]);
---END---
---START---
      end loop;
---END---
---START---
      cmd := cmd || ', unnest(' || quote_ident(fk.fkcols[nkeys]);
---END---
---START---
      cmd := cmd || ') as ' || quote_ident(fk.fkcols[nkeys]);
---END---
---START---
      cmd := cmd || ' FROM ' || fk.fktable::text || ') fk WHERE ';
---END---
---START---
    else
      cmd := cmd || ' FROM ' || fk.fktable::text || ' fk WHERE ';
---END---
---START---
    end if;
---END---
---START---
    if fk.is_opt then
      for i in 1 .. nkeys loop
        cmd := cmd || quote_ident(fk.fkcols[i]) || ' != 0 AND ';
---END---
---START---
      end loop;
---END---
---START---
    end if;
---END---
---START---
    cmd := cmd || 'NOT EXISTS(SELECT 1 FROM ' || fk.pktable::text || ' pk WHERE ';
---END---
---START---
    for i in 1 .. nkeys loop
      if i > 1 then cmd := cmd || ' AND '; end if;
---END---
---START---
      cmd := cmd || 'pk.' || quote_ident(fk.pkcols[i]);
---END---
---START---
      cmd := cmd || ' = fk.' || quote_ident(fk.fkcols[i]);
---END---
---START---
    end loop;
---END---
---START---
    cmd := cmd || ')';
---END---
---START---
    -- raise notice 'cmd = %', cmd;
---END---
---START---
    for err in execute cmd loop
      raise warning 'FK VIOLATION IN %(%): %', fk.fktable, fk.fkcols, err;
---END---
---START---
    end loop;
---END---
---START---
  end loop;
---END---
---START---
end
$doblock$;
---END---
