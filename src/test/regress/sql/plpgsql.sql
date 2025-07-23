---START---
--
-- PLPGSQL
--
-- Scenario:
--
--     A building with a modern TP cable installation where any
--     of the wall connectors can be used to plug in phones,
--     ethernet interfaces or local office hubs. The backside
--     of the wall connectors is wired to one of several patch-
--     fields in the building.
--
--     In the patchfields, there are hubs and all the slots
--     representing the wall connectors. In addition there are
--     slots that can represent a phone line from the central
--     phone system.
--
--     Triggers ensure consistency of the patching information.
--
--     Functions are used to build up powerful views that let
--     you look behind the wall when looking at a patchfield
--     or into a room.
--


create table Room (
    roomno	char(8),
    comment	text
);
---END---
---START---

create unique index Room_rno on Room using btree (roomno bpchar_ops);
---END---
---START---


create table WSlot (
    slotname	char(20),
    roomno	char(8),
    slotlink	char(20),
    backlink	char(20)
);
---END---
---START---

create unique index WSlot_name on WSlot using btree (slotname bpchar_ops);
---END---
---START---


create table PField (
    name	text,
    comment	text
);
---END---
---START---

create unique index PField_name on PField using btree (name text_ops);
---END---
---START---


create table PSlot (
    slotname	char(20),
    pfname	text,
    slotlink	char(20),
    backlink	char(20)
);
---END---
---START---

create unique index PSlot_name on PSlot using btree (slotname bpchar_ops);
---END---
---START---


create table PLine (
    slotname	char(20),
    phonenumber	char(20),
    comment	text,
    backlink	char(20)
);
---END---
---START---

create unique index PLine_name on PLine using btree (slotname bpchar_ops);
---END---
---START---


create table Hub (
    name	char(14),
    comment	text,
    nslots	integer
);
---END---
---START---

create unique index Hub_name on Hub using btree (name bpchar_ops);
---END---
---START---


create table HSlot (
    slotname	char(20),
    hubname	char(14),
    slotno	integer,
    slotlink	char(20)
);
---END---
---START---

create unique index HSlot_name on HSlot using btree (slotname bpchar_ops);
---END---
---START---
create index HSlot_hubname on HSlot using btree (hubname bpchar_ops);
---END---
---START---


create table System (
    name	text,
    comment	text
);
---END---
---START---

create unique index System_name on System using btree (name text_ops);
---END---
---START---


create table IFace (
    slotname	char(20),
    sysname	text,
    ifname	text,
    slotlink	char(20)
);
---END---
---START---

create unique index IFace_name on IFace using btree (slotname bpchar_ops);
---END---
---START---


create table PHone (
    slotname	char(20),
    comment	text,
    slotlink	char(20)
);
---END---
---START---

create unique index PHone_name on PHone using btree (slotname bpchar_ops);
---END---
---START---


-- ************************************************************
-- *
-- * Trigger procedures and functions for the patchfield
-- * test of PL/pgSQL
-- *
-- ************************************************************


-- ************************************************************
-- * AFTER UPDATE on Room
-- *	- If room no changes let wall slots follow
-- ************************************************************
create function tg_room_au() returns trigger as '
begin
    if new.roomno != old.roomno then
        update WSlot set roomno = new.roomno where roomno = old.roomno;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_room_au after update
    on Room for each row execute procedure tg_room_au();
---END---
---START---


-- ************************************************************
-- * AFTER DELETE on Room
-- *	- delete wall slots in this room
-- ************************************************************
create function tg_room_ad() returns trigger as '
begin
    delete from WSlot where roomno = old.roomno;
---END---
---START---
    return old;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_room_ad after delete
    on Room for each row execute procedure tg_room_ad();
---END---
---START---


-- ************************************************************
-- * BEFORE INSERT or UPDATE on WSlot
-- *	- Check that room exists
-- ************************************************************
create function tg_wslot_biu() returns trigger as $$
begin
    if count(*) = 0 from Room where roomno = new.roomno then
        raise exception 'Room % does not exist', new.roomno;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create trigger tg_wslot_biu before insert or update
    on WSlot for each row execute procedure tg_wslot_biu();
---END---
---START---


-- ************************************************************
-- * AFTER UPDATE on PField
-- *	- Let PSlots of this field follow
-- ************************************************************
create function tg_pfield_au() returns trigger as '
begin
    if new.name != old.name then
        update PSlot set pfname = new.name where pfname = old.name;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_pfield_au after update
    on PField for each row execute procedure tg_pfield_au();
---END---
---START---


-- ************************************************************
-- * AFTER DELETE on PField
-- *	- Remove all slots of this patchfield
-- ************************************************************
create function tg_pfield_ad() returns trigger as '
begin
    delete from PSlot where pfname = old.name;
---END---
---START---
    return old;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_pfield_ad after delete
    on PField for each row execute procedure tg_pfield_ad();
---END---
---START---


-- ************************************************************
-- * BEFORE INSERT or UPDATE on PSlot
-- *	- Ensure that our patchfield does exist
-- ************************************************************
create function tg_pslot_biu() returns trigger as $proc$
declare
    pfrec	record;
---END---
---START---
    ps          alias for new;
---END---
---START---
begin
    select into pfrec * from PField where name = ps.pfname;
---END---
---START---
    if not found then
        raise exception $$Patchfield "%" does not exist$$, ps.pfname;
---END---
---START---
    end if;
---END---
---START---
    return ps;
---END---
---START---
end;
---END---
---START---
$proc$ language plpgsql;
---END---
---START---

create trigger tg_pslot_biu before insert or update
    on PSlot for each row execute procedure tg_pslot_biu();
---END---
---START---


-- ************************************************************
-- * AFTER UPDATE on System
-- *	- If system name changes let interfaces follow
-- ************************************************************
create function tg_system_au() returns trigger as '
begin
    if new.name != old.name then
        update IFace set sysname = new.name where sysname = old.name;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_system_au after update
    on System for each row execute procedure tg_system_au();
---END---
---START---


-- ************************************************************
-- * BEFORE INSERT or UPDATE on IFace
-- *	- set the slotname to IF.sysname.ifname
-- ************************************************************
create function tg_iface_biu() returns trigger as $$
declare
    sname	text;
---END---
---START---
    sysrec	record;
---END---
---START---
begin
    select into sysrec * from system where name = new.sysname;
---END---
---START---
    if not found then
        raise exception $q$system "%" does not exist$q$, new.sysname;
---END---
---START---
    end if;
---END---
---START---
    sname := 'IF.' || new.sysname;
---END---
---START---
    sname := sname || '.';
---END---
---START---
    sname := sname || new.ifname;
---END---
---START---
    if length(sname) > 20 then
        raise exception 'IFace slotname "%" too long (20 char max)', sname;
---END---
---START---
    end if;
---END---
---START---
    new.slotname := sname;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create trigger tg_iface_biu before insert or update
    on IFace for each row execute procedure tg_iface_biu();
---END---
---START---


-- ************************************************************
-- * AFTER INSERT or UPDATE or DELETE on Hub
-- *	- insert/delete/rename slots as required
-- ************************************************************
create function tg_hub_a() returns trigger as '
declare
    hname	text;
---END---
---START---
    dummy	integer;
---END---
---START---
begin
    if tg_op = ''INSERT'' then
	dummy := tg_hub_adjustslots(new.name, 0, new.nslots);
---END---
---START---
	return new;
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''UPDATE'' then
	if new.name != old.name then
	    update HSlot set hubname = new.name where hubname = old.name;
---END---
---START---
	end if;
---END---
---START---
	dummy := tg_hub_adjustslots(new.name, old.nslots, new.nslots);
---END---
---START---
	return new;
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''DELETE'' then
	dummy := tg_hub_adjustslots(old.name, old.nslots, 0);
---END---
---START---
	return old;
---END---
---START---
    end if;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_hub_a after insert or update or delete
    on Hub for each row execute procedure tg_hub_a();
---END---
---START---


-- ************************************************************
-- * Support function to add/remove slots of Hub
-- ************************************************************
create function tg_hub_adjustslots(hname bpchar,
                                   oldnslots integer,
                                   newnslots integer)
returns integer as '
begin
    if newnslots = oldnslots then
        return 0;
---END---
---START---
    end if;
---END---
---START---
    if newnslots < oldnslots then
        delete from HSlot where hubname = hname and slotno > newnslots;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    for i in oldnslots + 1 .. newnslots loop
        insert into HSlot (slotname, hubname, slotno, slotlink)
		values (''HS.dummy'', hname, i, '''');
---END---
---START---
    end loop;
---END---
---START---
    return 0;
---END---
---START---
end
' language plpgsql;
---END---
---START---

-- Test comments
COMMENT ON FUNCTION tg_hub_adjustslots_wrong(bpchar, integer, integer) IS 'function with args';
---END---
---START---
COMMENT ON FUNCTION tg_hub_adjustslots(bpchar, integer, integer) IS 'function with args';
---END---
---START---
COMMENT ON FUNCTION tg_hub_adjustslots(bpchar, integer, integer) IS NULL;
---END---
---START---

-- ************************************************************
-- * BEFORE INSERT or UPDATE on HSlot
-- *	- prevent from manual manipulation
-- *	- set the slotname to HS.hubname.slotno
-- ************************************************************
create function tg_hslot_biu() returns trigger as '
declare
    sname	text;
---END---
---START---
    xname	HSlot.slotname%TYPE;
---END---
---START---
    hubrec	record;
---END---
---START---
begin
    select into hubrec * from Hub where name = new.hubname;
---END---
---START---
    if not found then
        raise exception ''no manual manipulation of HSlot'';
---END---
---START---
    end if;
---END---
---START---
    if new.slotno < 1 or new.slotno > hubrec.nslots then
        raise exception ''no manual manipulation of HSlot'';
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''UPDATE'' and new.hubname != old.hubname then
	if count(*) > 0 from Hub where name = old.hubname then
	    raise exception ''no manual manipulation of HSlot'';
---END---
---START---
	end if;
---END---
---START---
    end if;
---END---
---START---
    sname := ''HS.'' || trim(new.hubname);
---END---
---START---
    sname := sname || ''.'';
---END---
---START---
    sname := sname || new.slotno::text;
---END---
---START---
    if length(sname) > 20 then
        raise exception ''HSlot slotname "%" too long (20 char max)'', sname;
---END---
---START---
    end if;
---END---
---START---
    new.slotname := sname;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_hslot_biu before insert or update
    on HSlot for each row execute procedure tg_hslot_biu();
---END---
---START---


-- ************************************************************
-- * BEFORE DELETE on HSlot
-- *	- prevent from manual manipulation
-- ************************************************************
create function tg_hslot_bd() returns trigger as '
declare
    hubrec	record;
---END---
---START---
begin
    select into hubrec * from Hub where name = old.hubname;
---END---
---START---
    if not found then
        return old;
---END---
---START---
    end if;
---END---
---START---
    if old.slotno > hubrec.nslots then
        return old;
---END---
---START---
    end if;
---END---
---START---
    raise exception ''no manual manipulation of HSlot'';
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_hslot_bd before delete
    on HSlot for each row execute procedure tg_hslot_bd();
---END---
---START---


-- ************************************************************
-- * BEFORE INSERT on all slots
-- *	- Check name prefix
-- ************************************************************
create function tg_chkslotname() returns trigger as '
begin
    if substr(new.slotname, 1, 2) != tg_argv[0] then
        raise exception ''slotname must begin with %'', tg_argv[0];
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_chkslotname before insert
    on PSlot for each row execute procedure tg_chkslotname('PS');
---END---
---START---

create trigger tg_chkslotname before insert
    on WSlot for each row execute procedure tg_chkslotname('WS');
---END---
---START---

create trigger tg_chkslotname before insert
    on PLine for each row execute procedure tg_chkslotname('PL');
---END---
---START---

create trigger tg_chkslotname before insert
    on IFace for each row execute procedure tg_chkslotname('IF');
---END---
---START---

create trigger tg_chkslotname before insert
    on PHone for each row execute procedure tg_chkslotname('PH');
---END---
---START---


-- ************************************************************
-- * BEFORE INSERT or UPDATE on all slots with slotlink
-- *	- Set slotlink to empty string if NULL value given
-- ************************************************************
create function tg_chkslotlink() returns trigger as '
begin
    if new.slotlink isnull then
        new.slotlink := '''';
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_chkslotlink before insert or update
    on PSlot for each row execute procedure tg_chkslotlink();
---END---
---START---

create trigger tg_chkslotlink before insert or update
    on WSlot for each row execute procedure tg_chkslotlink();
---END---
---START---

create trigger tg_chkslotlink before insert or update
    on IFace for each row execute procedure tg_chkslotlink();
---END---
---START---

create trigger tg_chkslotlink before insert or update
    on HSlot for each row execute procedure tg_chkslotlink();
---END---
---START---

create trigger tg_chkslotlink before insert or update
    on PHone for each row execute procedure tg_chkslotlink();
---END---
---START---


-- ************************************************************
-- * BEFORE INSERT or UPDATE on all slots with backlink
-- *	- Set backlink to empty string if NULL value given
-- ************************************************************
create function tg_chkbacklink() returns trigger as '
begin
    if new.backlink isnull then
        new.backlink := '''';
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_chkbacklink before insert or update
    on PSlot for each row execute procedure tg_chkbacklink();
---END---
---START---

create trigger tg_chkbacklink before insert or update
    on WSlot for each row execute procedure tg_chkbacklink();
---END---
---START---

create trigger tg_chkbacklink before insert or update
    on PLine for each row execute procedure tg_chkbacklink();
---END---
---START---


-- ************************************************************
-- * BEFORE UPDATE on PSlot
-- *	- do delete/insert instead of update if name changes
-- ************************************************************
create function tg_pslot_bu() returns trigger as '
begin
    if new.slotname != old.slotname then
        delete from PSlot where slotname = old.slotname;
---END---
---START---
	insert into PSlot (
		    slotname,
		    pfname,
		    slotlink,
		    backlink
		) values (
		    new.slotname,
		    new.pfname,
		    new.slotlink,
		    new.backlink
		);
---END---
---START---
        return null;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_pslot_bu before update
    on PSlot for each row execute procedure tg_pslot_bu();
---END---
---START---


-- ************************************************************
-- * BEFORE UPDATE on WSlot
-- *	- do delete/insert instead of update if name changes
-- ************************************************************
create function tg_wslot_bu() returns trigger as '
begin
    if new.slotname != old.slotname then
        delete from WSlot where slotname = old.slotname;
---END---
---START---
	insert into WSlot (
		    slotname,
		    roomno,
		    slotlink,
		    backlink
		) values (
		    new.slotname,
		    new.roomno,
		    new.slotlink,
		    new.backlink
		);
---END---
---START---
        return null;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_wslot_bu before update
    on WSlot for each row execute procedure tg_Wslot_bu();
---END---
---START---


-- ************************************************************
-- * BEFORE UPDATE on PLine
-- *	- do delete/insert instead of update if name changes
-- ************************************************************
create function tg_pline_bu() returns trigger as '
begin
    if new.slotname != old.slotname then
        delete from PLine where slotname = old.slotname;
---END---
---START---
	insert into PLine (
		    slotname,
		    phonenumber,
		    comment,
		    backlink
		) values (
		    new.slotname,
		    new.phonenumber,
		    new.comment,
		    new.backlink
		);
---END---
---START---
        return null;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_pline_bu before update
    on PLine for each row execute procedure tg_pline_bu();
---END---
---START---


-- ************************************************************
-- * BEFORE UPDATE on IFace
-- *	- do delete/insert instead of update if name changes
-- ************************************************************
create function tg_iface_bu() returns trigger as '
begin
    if new.slotname != old.slotname then
        delete from IFace where slotname = old.slotname;
---END---
---START---
	insert into IFace (
		    slotname,
		    sysname,
		    ifname,
		    slotlink
		) values (
		    new.slotname,
		    new.sysname,
		    new.ifname,
		    new.slotlink
		);
---END---
---START---
        return null;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_iface_bu before update
    on IFace for each row execute procedure tg_iface_bu();
---END---
---START---


-- ************************************************************
-- * BEFORE UPDATE on HSlot
-- *	- do delete/insert instead of update if name changes
-- ************************************************************
create function tg_hslot_bu() returns trigger as '
begin
    if new.slotname != old.slotname or new.hubname != old.hubname then
        delete from HSlot where slotname = old.slotname;
---END---
---START---
	insert into HSlot (
		    slotname,
		    hubname,
		    slotno,
		    slotlink
		) values (
		    new.slotname,
		    new.hubname,
		    new.slotno,
		    new.slotlink
		);
---END---
---START---
        return null;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_hslot_bu before update
    on HSlot for each row execute procedure tg_hslot_bu();
---END---
---START---


-- ************************************************************
-- * BEFORE UPDATE on PHone
-- *	- do delete/insert instead of update if name changes
-- ************************************************************
create function tg_phone_bu() returns trigger as '
begin
    if new.slotname != old.slotname then
        delete from PHone where slotname = old.slotname;
---END---
---START---
	insert into PHone (
		    slotname,
		    comment,
		    slotlink
		) values (
		    new.slotname,
		    new.comment,
		    new.slotlink
		);
---END---
---START---
        return null;
---END---
---START---
    end if;
---END---
---START---
    return new;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---

create trigger tg_phone_bu before update
    on PHone for each row execute procedure tg_phone_bu();
---END---
---START---


-- ************************************************************
-- * AFTER INSERT or UPDATE or DELETE on slot with backlink
-- *	- Ensure that the opponent correctly points back to us
-- ************************************************************
create function tg_backlink_a() returns trigger as '
declare
    dummy	integer;
---END---
---START---
begin
    if tg_op = ''INSERT'' then
        if new.backlink != '''' then
	    dummy := tg_backlink_set(new.backlink, new.slotname);
---END---
---START---
	end if;
---END---
---START---
	return new;
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''UPDATE'' then
        if new.backlink != old.backlink then
	    if old.backlink != '''' then
	        dummy := tg_backlink_unset(old.backlink, old.slotname);
---END---
---START---
	    end if;
---END---
---START---
	    if new.backlink != '''' then
	        dummy := tg_backlink_set(new.backlink, new.slotname);
---END---
---START---
	    end if;
---END---
---START---
	else
	    if new.slotname != old.slotname and new.backlink != '''' then
	        dummy := tg_slotlink_set(new.backlink, new.slotname);
---END---
---START---
	    end if;
---END---
---START---
	end if;
---END---
---START---
	return new;
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''DELETE'' then
        if old.backlink != '''' then
	    dummy := tg_backlink_unset(old.backlink, old.slotname);
---END---
---START---
	end if;
---END---
---START---
	return old;
---END---
---START---
    end if;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


create trigger tg_backlink_a after insert or update or delete
    on PSlot for each row execute procedure tg_backlink_a('PS');
---END---
---START---

create trigger tg_backlink_a after insert or update or delete
    on WSlot for each row execute procedure tg_backlink_a('WS');
---END---
---START---

create trigger tg_backlink_a after insert or update or delete
    on PLine for each row execute procedure tg_backlink_a('PL');
---END---
---START---


-- ************************************************************
-- * Support function to set the opponents backlink field
-- * if it does not already point to the requested slot
-- ************************************************************
create function tg_backlink_set(myname bpchar, blname bpchar)
returns integer as '
declare
    mytype	char(2);
---END---
---START---
    link	char(4);
---END---
---START---
    rec		record;
---END---
---START---
begin
    mytype := substr(myname, 1, 2);
---END---
---START---
    link := mytype || substr(blname, 1, 2);
---END---
---START---
    if link = ''PLPL'' then
        raise exception
		''backlink between two phone lines does not make sense'';
---END---
---START---
    end if;
---END---
---START---
    if link in (''PLWS'', ''WSPL'') then
        raise exception
		''direct link of phone line to wall slot not permitted'';
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''PS'' then
        select into rec * from PSlot where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.backlink != blname then
	    update PSlot set backlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''WS'' then
        select into rec * from WSlot where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.backlink != blname then
	    update WSlot set backlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''PL'' then
        select into rec * from PLine where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.backlink != blname then
	    update PLine set backlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    raise exception ''illegal backlink beginning with %'', mytype;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


-- ************************************************************
-- * Support function to clear out the backlink field if
-- * it still points to specific slot
-- ************************************************************
create function tg_backlink_unset(bpchar, bpchar)
returns integer as '
declare
    myname	alias for $1;
---END---
---START---
    blname	alias for $2;
---END---
---START---
    mytype	char(2);
---END---
---START---
    rec		record;
---END---
---START---
begin
    mytype := substr(myname, 1, 2);
---END---
---START---
    if mytype = ''PS'' then
        select into rec * from PSlot where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.backlink = blname then
	    update PSlot set backlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''WS'' then
        select into rec * from WSlot where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.backlink = blname then
	    update WSlot set backlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''PL'' then
        select into rec * from PLine where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.backlink = blname then
	    update PLine set backlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
end
' language plpgsql;
---END---
---START---


-- ************************************************************
-- * AFTER INSERT or UPDATE or DELETE on slot with slotlink
-- *	- Ensure that the opponent correctly points back to us
-- ************************************************************
create function tg_slotlink_a() returns trigger as '
declare
    dummy	integer;
---END---
---START---
begin
    if tg_op = ''INSERT'' then
        if new.slotlink != '''' then
	    dummy := tg_slotlink_set(new.slotlink, new.slotname);
---END---
---START---
	end if;
---END---
---START---
	return new;
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''UPDATE'' then
        if new.slotlink != old.slotlink then
	    if old.slotlink != '''' then
	        dummy := tg_slotlink_unset(old.slotlink, old.slotname);
---END---
---START---
	    end if;
---END---
---START---
	    if new.slotlink != '''' then
	        dummy := tg_slotlink_set(new.slotlink, new.slotname);
---END---
---START---
	    end if;
---END---
---START---
	else
	    if new.slotname != old.slotname and new.slotlink != '''' then
	        dummy := tg_slotlink_set(new.slotlink, new.slotname);
---END---
---START---
	    end if;
---END---
---START---
	end if;
---END---
---START---
	return new;
---END---
---START---
    end if;
---END---
---START---
    if tg_op = ''DELETE'' then
        if old.slotlink != '''' then
	    dummy := tg_slotlink_unset(old.slotlink, old.slotname);
---END---
---START---
	end if;
---END---
---START---
	return old;
---END---
---START---
    end if;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


create trigger tg_slotlink_a after insert or update or delete
    on PSlot for each row execute procedure tg_slotlink_a('PS');
---END---
---START---

create trigger tg_slotlink_a after insert or update or delete
    on WSlot for each row execute procedure tg_slotlink_a('WS');
---END---
---START---

create trigger tg_slotlink_a after insert or update or delete
    on IFace for each row execute procedure tg_slotlink_a('IF');
---END---
---START---

create trigger tg_slotlink_a after insert or update or delete
    on HSlot for each row execute procedure tg_slotlink_a('HS');
---END---
---START---

create trigger tg_slotlink_a after insert or update or delete
    on PHone for each row execute procedure tg_slotlink_a('PH');
---END---
---START---


-- ************************************************************
-- * Support function to set the opponents slotlink field
-- * if it does not already point to the requested slot
-- ************************************************************
create function tg_slotlink_set(bpchar, bpchar)
returns integer as '
declare
    myname	alias for $1;
---END---
---START---
    blname	alias for $2;
---END---
---START---
    mytype	char(2);
---END---
---START---
    link	char(4);
---END---
---START---
    rec		record;
---END---
---START---
begin
    mytype := substr(myname, 1, 2);
---END---
---START---
    link := mytype || substr(blname, 1, 2);
---END---
---START---
    if link = ''PHPH'' then
        raise exception
		''slotlink between two phones does not make sense'';
---END---
---START---
    end if;
---END---
---START---
    if link in (''PHHS'', ''HSPH'') then
        raise exception
		''link of phone to hub does not make sense'';
---END---
---START---
    end if;
---END---
---START---
    if link in (''PHIF'', ''IFPH'') then
        raise exception
		''link of phone to hub does not make sense'';
---END---
---START---
    end if;
---END---
---START---
    if link in (''PSWS'', ''WSPS'') then
        raise exception
		''slotlink from patchslot to wallslot not permitted'';
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''PS'' then
        select into rec * from PSlot where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink != blname then
	    update PSlot set slotlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''WS'' then
        select into rec * from WSlot where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink != blname then
	    update WSlot set slotlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''IF'' then
        select into rec * from IFace where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink != blname then
	    update IFace set slotlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''HS'' then
        select into rec * from HSlot where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink != blname then
	    update HSlot set slotlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''PH'' then
        select into rec * from PHone where slotname = myname;
---END---
---START---
	if not found then
	    raise exception ''% does not exist'', myname;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink != blname then
	    update PHone set slotlink = blname where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    raise exception ''illegal slotlink beginning with %'', mytype;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


-- ************************************************************
-- * Support function to clear out the slotlink field if
-- * it still points to specific slot
-- ************************************************************
create function tg_slotlink_unset(bpchar, bpchar)
returns integer as '
declare
    myname	alias for $1;
---END---
---START---
    blname	alias for $2;
---END---
---START---
    mytype	char(2);
---END---
---START---
    rec		record;
---END---
---START---
begin
    mytype := substr(myname, 1, 2);
---END---
---START---
    if mytype = ''PS'' then
        select into rec * from PSlot where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink = blname then
	    update PSlot set slotlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''WS'' then
        select into rec * from WSlot where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink = blname then
	    update WSlot set slotlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''IF'' then
        select into rec * from IFace where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink = blname then
	    update IFace set slotlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''HS'' then
        select into rec * from HSlot where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink = blname then
	    update HSlot set slotlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
    if mytype = ''PH'' then
        select into rec * from PHone where slotname = myname;
---END---
---START---
	if not found then
	    return 0;
---END---
---START---
	end if;
---END---
---START---
	if rec.slotlink = blname then
	    update PHone set slotlink = '''' where slotname = myname;
---END---
---START---
	end if;
---END---
---START---
	return 0;
---END---
---START---
    end if;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


-- ************************************************************
-- * Describe the backside of a patchfield slot
-- ************************************************************
create function pslot_backlink_view(bpchar)
returns text as '
<<outer>>
declare
    rec		record;
---END---
---START---
    bltype	char(2);
---END---
---START---
    retval	text;
---END---
---START---
begin
    select into rec * from PSlot where slotname = $1;
---END---
---START---
    if not found then
        return '''';
---END---
---START---
    end if;
---END---
---START---
    if rec.backlink = '''' then
        return ''-'';
---END---
---START---
    end if;
---END---
---START---
    bltype := substr(rec.backlink, 1, 2);
---END---
---START---
    if bltype = ''PL'' then
        declare
	    rec		record;
---END---
---START---
	begin
	    select into rec * from PLine where slotname = "outer".rec.backlink;
---END---
---START---
	    retval := ''Phone line '' || trim(rec.phonenumber);
---END---
---START---
	    if rec.comment != '''' then
	        retval := retval || '' ('';
---END---
---START---
		retval := retval || rec.comment;
---END---
---START---
		retval := retval || '')'';
---END---
---START---
	    end if;
---END---
---START---
	    return retval;
---END---
---START---
	end;
---END---
---START---
    end if;
---END---
---START---
    if bltype = ''WS'' then
        select into rec * from WSlot where slotname = rec.backlink;
---END---
---START---
	retval := trim(rec.slotname) || '' in room '';
---END---
---START---
	retval := retval || trim(rec.roomno);
---END---
---START---
	retval := retval || '' -> '';
---END---
---START---
	return retval || wslot_slotlink_view(rec.slotname);
---END---
---START---
    end if;
---END---
---START---
    return rec.backlink;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


-- ************************************************************
-- * Describe the front of a patchfield slot
-- ************************************************************
create function pslot_slotlink_view(bpchar)
returns text as '
declare
    psrec	record;
---END---
---START---
    sltype	char(2);
---END---
---START---
    retval	text;
---END---
---START---
begin
    select into psrec * from PSlot where slotname = $1;
---END---
---START---
    if not found then
        return '''';
---END---
---START---
    end if;
---END---
---START---
    if psrec.slotlink = '''' then
        return ''-'';
---END---
---START---
    end if;
---END---
---START---
    sltype := substr(psrec.slotlink, 1, 2);
---END---
---START---
    if sltype = ''PS'' then
	retval := trim(psrec.slotlink) || '' -> '';
---END---
---START---
	return retval || pslot_backlink_view(psrec.slotlink);
---END---
---START---
    end if;
---END---
---START---
    if sltype = ''HS'' then
        retval := comment from Hub H, HSlot HS
			where HS.slotname = psrec.slotlink
			  and H.name = HS.hubname;
---END---
---START---
        retval := retval || '' slot '';
---END---
---START---
	retval := retval || slotno::text from HSlot
			where slotname = psrec.slotlink;
---END---
---START---
	return retval;
---END---
---START---
    end if;
---END---
---START---
    return psrec.slotlink;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---


-- ************************************************************
-- * Describe the front of a wall connector slot
-- ************************************************************
create function wslot_slotlink_view(bpchar)
returns text as '
declare
    rec		record;
---END---
---START---
    sltype	char(2);
---END---
---START---
    retval	text;
---END---
---START---
begin
    select into rec * from WSlot where slotname = $1;
---END---
---START---
    if not found then
        return '''';
---END---
---START---
    end if;
---END---
---START---
    if rec.slotlink = '''' then
        return ''-'';
---END---
---START---
    end if;
---END---
---START---
    sltype := substr(rec.slotlink, 1, 2);
---END---
---START---
    if sltype = ''PH'' then
        select into rec * from PHone where slotname = rec.slotlink;
---END---
---START---
	retval := ''Phone '' || trim(rec.slotname);
---END---
---START---
	if rec.comment != '''' then
	    retval := retval || '' ('';
---END---
---START---
	    retval := retval || rec.comment;
---END---
---START---
	    retval := retval || '')'';
---END---
---START---
	end if;
---END---
---START---
	return retval;
---END---
---START---
    end if;
---END---
---START---
    if sltype = ''IF'' then
	declare
	    syrow	System%RowType;
---END---
---START---
	    ifrow	IFace%ROWTYPE;
---END---
---START---
        begin
	    select into ifrow * from IFace where slotname = rec.slotlink;
---END---
---START---
	    select into syrow * from System where name = ifrow.sysname;
---END---
---START---
	    retval := syrow.name || '' IF '';
---END---
---START---
	    retval := retval || ifrow.ifname;
---END---
---START---
	    if syrow.comment != '''' then
	        retval := retval || '' ('';
---END---
---START---
		retval := retval || syrow.comment;
---END---
---START---
		retval := retval || '')'';
---END---
---START---
	    end if;
---END---
---START---
	    return retval;
---END---
---START---
	end;
---END---
---START---
    end if;
---END---
---START---
    return rec.slotlink;
---END---
---START---
end;
---END---
---START---
' language plpgsql;
---END---
---START---



-- ************************************************************
-- * View of a patchfield describing backside and patches
-- ************************************************************
create view Pfield_v1 as select PF.pfname, PF.slotname,
	pslot_backlink_view(PF.slotname) as backside,
	pslot_slotlink_view(PF.slotname) as patch
    from PSlot PF;
---END---
---START---


--
-- First we build the house - so we create the rooms
--
insert into Room values ('001', 'Entrance');
---END---
---START---
insert into Room values ('002', 'Office');
---END---
---START---
insert into Room values ('003', 'Office');
---END---
---START---
insert into Room values ('004', 'Technical');
---END---
---START---
insert into Room values ('101', 'Office');
---END---
---START---
insert into Room values ('102', 'Conference');
---END---
---START---
insert into Room values ('103', 'Restroom');
---END---
---START---
insert into Room values ('104', 'Technical');
---END---
---START---
insert into Room values ('105', 'Office');
---END---
---START---
insert into Room values ('106', 'Office');
---END---
---START---

--
-- Second we install the wall connectors
--
insert into WSlot values ('WS.001.1a', '001', '', '');
---END---
---START---
insert into WSlot values ('WS.001.1b', '001', '', '');
---END---
---START---
insert into WSlot values ('WS.001.2a', '001', '', '');
---END---
---START---
insert into WSlot values ('WS.001.2b', '001', '', '');
---END---
---START---
insert into WSlot values ('WS.001.3a', '001', '', '');
---END---
---START---
insert into WSlot values ('WS.001.3b', '001', '', '');
---END---
---START---

insert into WSlot values ('WS.002.1a', '002', '', '');
---END---
---START---
insert into WSlot values ('WS.002.1b', '002', '', '');
---END---
---START---
insert into WSlot values ('WS.002.2a', '002', '', '');
---END---
---START---
insert into WSlot values ('WS.002.2b', '002', '', '');
---END---
---START---
insert into WSlot values ('WS.002.3a', '002', '', '');
---END---
---START---
insert into WSlot values ('WS.002.3b', '002', '', '');
---END---
---START---

insert into WSlot values ('WS.003.1a', '003', '', '');
---END---
---START---
insert into WSlot values ('WS.003.1b', '003', '', '');
---END---
---START---
insert into WSlot values ('WS.003.2a', '003', '', '');
---END---
---START---
insert into WSlot values ('WS.003.2b', '003', '', '');
---END---
---START---
insert into WSlot values ('WS.003.3a', '003', '', '');
---END---
---START---
insert into WSlot values ('WS.003.3b', '003', '', '');
---END---
---START---

insert into WSlot values ('WS.101.1a', '101', '', '');
---END---
---START---
insert into WSlot values ('WS.101.1b', '101', '', '');
---END---
---START---
insert into WSlot values ('WS.101.2a', '101', '', '');
---END---
---START---
insert into WSlot values ('WS.101.2b', '101', '', '');
---END---
---START---
insert into WSlot values ('WS.101.3a', '101', '', '');
---END---
---START---
insert into WSlot values ('WS.101.3b', '101', '', '');
---END---
---START---

insert into WSlot values ('WS.102.1a', '102', '', '');
---END---
---START---
insert into WSlot values ('WS.102.1b', '102', '', '');
---END---
---START---
insert into WSlot values ('WS.102.2a', '102', '', '');
---END---
---START---
insert into WSlot values ('WS.102.2b', '102', '', '');
---END---
---START---
insert into WSlot values ('WS.102.3a', '102', '', '');
---END---
---START---
insert into WSlot values ('WS.102.3b', '102', '', '');
---END---
---START---

insert into WSlot values ('WS.105.1a', '105', '', '');
---END---
---START---
insert into WSlot values ('WS.105.1b', '105', '', '');
---END---
---START---
insert into WSlot values ('WS.105.2a', '105', '', '');
---END---
---START---
insert into WSlot values ('WS.105.2b', '105', '', '');
---END---
---START---
insert into WSlot values ('WS.105.3a', '105', '', '');
---END---
---START---
insert into WSlot values ('WS.105.3b', '105', '', '');
---END---
---START---

insert into WSlot values ('WS.106.1a', '106', '', '');
---END---
---START---
insert into WSlot values ('WS.106.1b', '106', '', '');
---END---
---START---
insert into WSlot values ('WS.106.2a', '106', '', '');
---END---
---START---
insert into WSlot values ('WS.106.2b', '106', '', '');
---END---
---START---
insert into WSlot values ('WS.106.3a', '106', '', '');
---END---
---START---
insert into WSlot values ('WS.106.3b', '106', '', '');
---END---
---START---

--
-- Now create the patch fields and their slots
--
insert into PField values ('PF0_1', 'Wallslots basement');
---END---
---START---

--
-- The cables for these will be made later, so they are unconnected for now
--
insert into PSlot values ('PS.base.a1', 'PF0_1', '', '');
---END---
---START---
insert into PSlot values ('PS.base.a2', 'PF0_1', '', '');
---END---
---START---
insert into PSlot values ('PS.base.a3', 'PF0_1', '', '');
---END---
---START---
insert into PSlot values ('PS.base.a4', 'PF0_1', '', '');
---END---
---START---
insert into PSlot values ('PS.base.a5', 'PF0_1', '', '');
---END---
---START---
insert into PSlot values ('PS.base.a6', 'PF0_1', '', '');
---END---
---START---

--
-- These are already wired to the wall connectors
--
insert into PSlot values ('PS.base.b1', 'PF0_1', '', 'WS.002.1a');
---END---
---START---
insert into PSlot values ('PS.base.b2', 'PF0_1', '', 'WS.002.1b');
---END---
---START---
insert into PSlot values ('PS.base.b3', 'PF0_1', '', 'WS.002.2a');
---END---
---START---
insert into PSlot values ('PS.base.b4', 'PF0_1', '', 'WS.002.2b');
---END---
---START---
insert into PSlot values ('PS.base.b5', 'PF0_1', '', 'WS.002.3a');
---END---
---START---
insert into PSlot values ('PS.base.b6', 'PF0_1', '', 'WS.002.3b');
---END---
---START---

insert into PSlot values ('PS.base.c1', 'PF0_1', '', 'WS.003.1a');
---END---
---START---
insert into PSlot values ('PS.base.c2', 'PF0_1', '', 'WS.003.1b');
---END---
---START---
insert into PSlot values ('PS.base.c3', 'PF0_1', '', 'WS.003.2a');
---END---
---START---
insert into PSlot values ('PS.base.c4', 'PF0_1', '', 'WS.003.2b');
---END---
---START---
insert into PSlot values ('PS.base.c5', 'PF0_1', '', 'WS.003.3a');
---END---
---START---
insert into PSlot values ('PS.base.c6', 'PF0_1', '', 'WS.003.3b');
---END---
---START---

--
-- This patchfield will be renamed later into PF0_2 - so its
-- slots references in pfname should follow
--
insert into PField values ('PF0_X', 'Phonelines basement');
---END---
---START---

insert into PSlot values ('PS.base.ta1', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.ta2', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.ta3', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.ta4', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.ta5', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.ta6', 'PF0_X', '', '');
---END---
---START---

insert into PSlot values ('PS.base.tb1', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.tb2', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.tb3', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.tb4', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.tb5', 'PF0_X', '', '');
---END---
---START---
insert into PSlot values ('PS.base.tb6', 'PF0_X', '', '');
---END---
---START---

insert into PField values ('PF1_1', 'Wallslots first floor');
---END---
---START---

insert into PSlot values ('PS.first.a1', 'PF1_1', '', 'WS.101.1a');
---END---
---START---
insert into PSlot values ('PS.first.a2', 'PF1_1', '', 'WS.101.1b');
---END---
---START---
insert into PSlot values ('PS.first.a3', 'PF1_1', '', 'WS.101.2a');
---END---
---START---
insert into PSlot values ('PS.first.a4', 'PF1_1', '', 'WS.101.2b');
---END---
---START---
insert into PSlot values ('PS.first.a5', 'PF1_1', '', 'WS.101.3a');
---END---
---START---
insert into PSlot values ('PS.first.a6', 'PF1_1', '', 'WS.101.3b');
---END---
---START---

insert into PSlot values ('PS.first.b1', 'PF1_1', '', 'WS.102.1a');
---END---
---START---
insert into PSlot values ('PS.first.b2', 'PF1_1', '', 'WS.102.1b');
---END---
---START---
insert into PSlot values ('PS.first.b3', 'PF1_1', '', 'WS.102.2a');
---END---
---START---
insert into PSlot values ('PS.first.b4', 'PF1_1', '', 'WS.102.2b');
---END---
---START---
insert into PSlot values ('PS.first.b5', 'PF1_1', '', 'WS.102.3a');
---END---
---START---
insert into PSlot values ('PS.first.b6', 'PF1_1', '', 'WS.102.3b');
---END---
---START---

insert into PSlot values ('PS.first.c1', 'PF1_1', '', 'WS.105.1a');
---END---
---START---
insert into PSlot values ('PS.first.c2', 'PF1_1', '', 'WS.105.1b');
---END---
---START---
insert into PSlot values ('PS.first.c3', 'PF1_1', '', 'WS.105.2a');
---END---
---START---
insert into PSlot values ('PS.first.c4', 'PF1_1', '', 'WS.105.2b');
---END---
---START---
insert into PSlot values ('PS.first.c5', 'PF1_1', '', 'WS.105.3a');
---END---
---START---
insert into PSlot values ('PS.first.c6', 'PF1_1', '', 'WS.105.3b');
---END---
---START---

insert into PSlot values ('PS.first.d1', 'PF1_1', '', 'WS.106.1a');
---END---
---START---
insert into PSlot values ('PS.first.d2', 'PF1_1', '', 'WS.106.1b');
---END---
---START---
insert into PSlot values ('PS.first.d3', 'PF1_1', '', 'WS.106.2a');
---END---
---START---
insert into PSlot values ('PS.first.d4', 'PF1_1', '', 'WS.106.2b');
---END---
---START---
insert into PSlot values ('PS.first.d5', 'PF1_1', '', 'WS.106.3a');
---END---
---START---
insert into PSlot values ('PS.first.d6', 'PF1_1', '', 'WS.106.3b');
---END---
---START---

--
-- Now we wire the wall connectors 1a-2a in room 001 to the
-- patchfield. In the second update we make an error, and
-- correct it after
--
update PSlot set backlink = 'WS.001.1a' where slotname = 'PS.base.a1';
---END---
---START---
update PSlot set backlink = 'WS.001.1b' where slotname = 'PS.base.a3';
---END---
---START---
select * from WSlot where roomno = '001' order by slotname;
---END---
---START---
select * from PSlot where slotname ~ 'PS.base.a' order by slotname;
---END---
---START---
update PSlot set backlink = 'WS.001.2a' where slotname = 'PS.base.a3';
---END---
---START---
select * from WSlot where roomno = '001' order by slotname;
---END---
---START---
select * from PSlot where slotname ~ 'PS.base.a' order by slotname;
---END---
---START---
update PSlot set backlink = 'WS.001.1b' where slotname = 'PS.base.a2';
---END---
---START---
select * from WSlot where roomno = '001' order by slotname;
---END---
---START---
select * from PSlot where slotname ~ 'PS.base.a' order by slotname;
---END---
---START---

--
-- Same procedure for 2b-3b but this time updating the WSlot instead
-- of the PSlot. Due to the triggers the result is the same:
-- WSlot and corresponding PSlot point to each other.
--
update WSlot set backlink = 'PS.base.a4' where slotname = 'WS.001.2b';
---END---
---START---
update WSlot set backlink = 'PS.base.a6' where slotname = 'WS.001.3a';
---END---
---START---
select * from WSlot where roomno = '001' order by slotname;
---END---
---START---
select * from PSlot where slotname ~ 'PS.base.a' order by slotname;
---END---
---START---
update WSlot set backlink = 'PS.base.a6' where slotname = 'WS.001.3b';
---END---
---START---
select * from WSlot where roomno = '001' order by slotname;
---END---
---START---
select * from PSlot where slotname ~ 'PS.base.a' order by slotname;
---END---
---START---
update WSlot set backlink = 'PS.base.a5' where slotname = 'WS.001.3a';
---END---
---START---
select * from WSlot where roomno = '001' order by slotname;
---END---
---START---
select * from PSlot where slotname ~ 'PS.base.a' order by slotname;
---END---
---START---

insert into PField values ('PF1_2', 'Phonelines first floor');
---END---
---START---

insert into PSlot values ('PS.first.ta1', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.ta2', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.ta3', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.ta4', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.ta5', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.ta6', 'PF1_2', '', '');
---END---
---START---

insert into PSlot values ('PS.first.tb1', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.tb2', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.tb3', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.tb4', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.tb5', 'PF1_2', '', '');
---END---
---START---
insert into PSlot values ('PS.first.tb6', 'PF1_2', '', '');
---END---
---START---

--
-- Fix the wrong name for patchfield PF0_2
--
update PField set name = 'PF0_2' where name = 'PF0_X';
---END---
---START---

select * from PSlot order by slotname;
---END---
---START---
select * from WSlot order by slotname;
---END---
---START---

--
-- Install the central phone system and create the phone numbers.
-- They are wired on insert to the patchfields. Again the
-- triggers automatically tell the PSlots to update their
-- backlink field.
--
insert into PLine values ('PL.001', '-0', 'Central call', 'PS.base.ta1');
---END---
---START---
insert into PLine values ('PL.002', '-101', '', 'PS.base.ta2');
---END---
---START---
insert into PLine values ('PL.003', '-102', '', 'PS.base.ta3');
---END---
---START---
insert into PLine values ('PL.004', '-103', '', 'PS.base.ta5');
---END---
---START---
insert into PLine values ('PL.005', '-104', '', 'PS.base.ta6');
---END---
---START---
insert into PLine values ('PL.006', '-106', '', 'PS.base.tb2');
---END---
---START---
insert into PLine values ('PL.007', '-108', '', 'PS.base.tb3');
---END---
---START---
insert into PLine values ('PL.008', '-109', '', 'PS.base.tb4');
---END---
---START---
insert into PLine values ('PL.009', '-121', '', 'PS.base.tb5');
---END---
---START---
insert into PLine values ('PL.010', '-122', '', 'PS.base.tb6');
---END---
---START---
insert into PLine values ('PL.015', '-134', '', 'PS.first.ta1');
---END---
---START---
insert into PLine values ('PL.016', '-137', '', 'PS.first.ta3');
---END---
---START---
insert into PLine values ('PL.017', '-139', '', 'PS.first.ta4');
---END---
---START---
insert into PLine values ('PL.018', '-362', '', 'PS.first.tb1');
---END---
---START---
insert into PLine values ('PL.019', '-363', '', 'PS.first.tb2');
---END---
---START---
insert into PLine values ('PL.020', '-364', '', 'PS.first.tb3');
---END---
---START---
insert into PLine values ('PL.021', '-365', '', 'PS.first.tb5');
---END---
---START---
insert into PLine values ('PL.022', '-367', '', 'PS.first.tb6');
---END---
---START---
insert into PLine values ('PL.028', '-501', 'Fax entrance', 'PS.base.ta2');
---END---
---START---
insert into PLine values ('PL.029', '-502', 'Fax first floor', 'PS.first.ta1');
---END---
---START---

--
-- Buy some phones, plug them into the wall and patch the
-- phone lines to the corresponding patchfield slots.
--
insert into PHone values ('PH.hc001', 'Hicom standard', 'WS.001.1a');
---END---
---START---
update PSlot set slotlink = 'PS.base.ta1' where slotname = 'PS.base.a1';
---END---
---START---
insert into PHone values ('PH.hc002', 'Hicom standard', 'WS.002.1a');
---END---
---START---
update PSlot set slotlink = 'PS.base.ta5' where slotname = 'PS.base.b1';
---END---
---START---
insert into PHone values ('PH.hc003', 'Hicom standard', 'WS.002.2a');
---END---
---START---
update PSlot set slotlink = 'PS.base.tb2' where slotname = 'PS.base.b3';
---END---
---START---
insert into PHone values ('PH.fax001', 'Canon fax', 'WS.001.2a');
---END---
---START---
update PSlot set slotlink = 'PS.base.ta2' where slotname = 'PS.base.a3';
---END---
---START---

--
-- Install a hub at one of the patchfields, plug a computers
-- ethernet interface into the wall and patch it to the hub.
--
insert into Hub values ('base.hub1', 'Patchfield PF0_1 hub', 16);
---END---
---START---
insert into System values ('orion', 'PC');
---END---
---START---
insert into IFace values ('IF', 'orion', 'eth0', 'WS.002.1b');
---END---
---START---
update PSlot set slotlink = 'HS.base.hub1.1' where slotname = 'PS.base.b2';
---END---
---START---

--
-- Now we take a look at the patchfield
--
select * from PField_v1 where pfname = 'PF0_1' order by slotname;
---END---
---START---
select * from PField_v1 where pfname = 'PF0_2' order by slotname;
---END---
---START---

--
-- Finally we want errors
--
insert into PField values ('PF1_1', 'should fail due to unique index');
---END---
---START---
update PSlot set backlink = 'WS.not.there' where slotname = 'PS.base.a1';
---END---
---START---
update PSlot set backlink = 'XX.illegal' where slotname = 'PS.base.a1';
---END---
---START---
update PSlot set slotlink = 'PS.not.there' where slotname = 'PS.base.a1';
---END---
---START---
update PSlot set slotlink = 'XX.illegal' where slotname = 'PS.base.a1';
---END---
---START---
insert into HSlot values ('HS', 'base.hub1', 1, '');
---END---
---START---
insert into HSlot values ('HS', 'base.hub1', 20, '');
---END---
---START---
delete from HSlot;
---END---
---START---
insert into IFace values ('IF', 'notthere', 'eth0', '');
---END---
---START---
insert into IFace values ('IF', 'orion', 'ethernet_interface_name_too_long', '');
---END---
---START---


--
-- The following tests are unrelated to the scenario outlined above;
---END---
---START---
-- they merely exercise specific parts of PL/pgSQL
--

--
-- Test recursion, per bug report 7-Sep-01
--
CREATE FUNCTION recursion_test(int,int) RETURNS text AS '
DECLARE rslt text;
---END---
---START---
BEGIN
    IF $1 <= 0 THEN
        rslt = CAST($2 AS TEXT);
---END---
---START---
    ELSE
        rslt = CAST($1 AS TEXT) || '','' || recursion_test($1 - 1, $2);
---END---
---START---
    END IF;
---END---
---START---
    RETURN rslt;
---END---
---START---
END;' LANGUAGE plpgsql;
---END---
---START---

SELECT recursion_test(4,3);
---END---
---START---

--
-- Test the FOUND magic variable
--
CREATE TABLE found_test_tbl (a int);
---END---
---START---

create function test_found()
  returns boolean as '
  declare
  begin
  insert into found_test_tbl values (1);
---END---
---START---
  if FOUND then
     insert into found_test_tbl values (2);
---END---
---START---
  end if;
---END---
---START---

  update found_test_tbl set a = 100 where a = 1;
---END---
---START---
  if FOUND then
    insert into found_test_tbl values (3);
---END---
---START---
  end if;
---END---
---START---

  delete from found_test_tbl where a = 9999; -- matches no rows
  if not FOUND then
    insert into found_test_tbl values (4);
---END---
---START---
  end if;
---END---
---START---

  for i in 1 .. 10 loop
    -- no need to do anything
  end loop;
---END---
---START---
  if FOUND then
    insert into found_test_tbl values (5);
---END---
---START---
  end if;
---END---
---START---

  -- never executes the loop
  for i in 2 .. 1 loop
    -- no need to do anything
  end loop;
---END---
---START---
  if not FOUND then
    insert into found_test_tbl values (6);
---END---
---START---
  end if;
---END---
---START---
  return true;
---END---
---START---
  end;' language plpgsql;
---END---
---START---

select test_found();
---END---
---START---
select * from found_test_tbl;
---END---
---START---

--
-- Test set-returning functions for PL/pgSQL
--

create function test_table_func_rec() returns setof found_test_tbl as '
DECLARE
	rec RECORD;
---END---
---START---
BEGIN
	FOR rec IN select * from found_test_tbl LOOP
		RETURN NEXT rec;
---END---
---START---
	END LOOP;
---END---
---START---
	RETURN;
---END---
---START---
END;' language plpgsql;
---END---
---START---

select * from test_table_func_rec();
---END---
---START---

create function test_table_func_row() returns setof found_test_tbl as '
DECLARE
	row found_test_tbl%ROWTYPE;
---END---
---START---
BEGIN
	FOR row IN select * from found_test_tbl LOOP
		RETURN NEXT row;
---END---
---START---
	END LOOP;
---END---
---START---
	RETURN;
---END---
---START---
END;' language plpgsql;
---END---
---START---

select * from test_table_func_row();
---END---
---START---

create function test_ret_set_scalar(int,int) returns setof int as '
DECLARE
	i int;
---END---
---START---
BEGIN
	FOR i IN $1 .. $2 LOOP
		RETURN NEXT i + 1;
---END---
---START---
	END LOOP;
---END---
---START---
	RETURN;
---END---
---START---
END;' language plpgsql;
---END---
---START---

select * from test_ret_set_scalar(1,10);
---END---
---START---

create function test_ret_set_rec_dyn(int) returns setof record as '
DECLARE
	retval RECORD;
---END---
---START---
BEGIN
	IF $1 > 10 THEN
		SELECT INTO retval 5, 10, 15;
---END---
---START---
		RETURN NEXT retval;
---END---
---START---
		RETURN NEXT retval;
---END---
---START---
	ELSE
		SELECT INTO retval 50, 5::numeric, ''xxx''::text;
---END---
---START---
		RETURN NEXT retval;
---END---
---START---
		RETURN NEXT retval;
---END---
---START---
	END IF;
---END---
---START---
	RETURN;
---END---
---START---
END;' language plpgsql;
---END---
---START---

SELECT * FROM test_ret_set_rec_dyn(1500) AS (a int, b int, c int);
---END---
---START---
SELECT * FROM test_ret_set_rec_dyn(5) AS (a int, b numeric, c text);
---END---
---START---

create function test_ret_rec_dyn(int) returns record as '
DECLARE
	retval RECORD;
---END---
---START---
BEGIN
	IF $1 > 10 THEN
		SELECT INTO retval 5, 10, 15;
---END---
---START---
		RETURN retval;
---END---
---START---
	ELSE
		SELECT INTO retval 50, 5::numeric, ''xxx''::text;
---END---
---START---
		RETURN retval;
---END---
---START---
	END IF;
---END---
---START---
END;' language plpgsql;
---END---
---START---

SELECT * FROM test_ret_rec_dyn(1500) AS (a int, b int, c int);
---END---
---START---
SELECT * FROM test_ret_rec_dyn(5) AS (a int, b numeric, c text);
---END---
---START---

--
-- Test some simple polymorphism cases.
--

create function f1(x anyelement) returns anyelement as $$
begin
  return x + 1;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(42) as int, f1(4.5) as num;
---END---
---START---
select f1(point(3,4));  -- fail for lack of + operator

drop function f1(x anyelement);
---END---
---START---

create function f1(x anyelement) returns anyarray as $$
begin
  return array[x + 1, x + 2];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(42) as int, f1(4.5) as num;
---END---
---START---

drop function f1(x anyelement);
---END---
---START---

create function f1(x anyarray) returns anyelement as $$
begin
  return x[1];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(array[2,4]) as int, f1(array[4.5, 7.7]) as num;
---END---
---START---

select f1(stavalues1) from pg_statistic;  -- fail, can't infer element type

drop function f1(x anyarray);
---END---
---START---

create function f1(x anyarray) returns anyarray as $$
begin
  return x;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(array[2,4]) as int, f1(array[4.5, 7.7]) as num;
---END---
---START---

select f1(stavalues1) from pg_statistic;  -- fail, can't infer element type

drop function f1(x anyarray);
---END---
---START---

-- fail, can't infer type:
create function f1(x anyelement) returns anyrange as $$
begin
  return array[x + 1, x + 2];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

create function f1(x anyrange) returns anyarray as $$
begin
  return array[lower(x), upper(x)];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(int4range(42, 49)) as int, f1(float8range(4.5, 7.8)) as num;
---END---
---START---

drop function f1(x anyrange);
---END---
---START---

create function f1(x anycompatible, y anycompatible) returns anycompatiblearray as $$
begin
  return array[x, y];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(2, 4) as int, f1(2, 4.5) as num;
---END---
---START---

drop function f1(x anycompatible, y anycompatible);
---END---
---START---

create function f1(x anycompatiblerange, y anycompatible, z anycompatible) returns anycompatiblearray as $$
begin
  return array[lower(x), upper(x), y, z];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(int4range(42, 49), 11, 2::smallint) as int, f1(float8range(4.5, 7.8), 7.8, 11::real) as num;
---END---
---START---

select f1(int4range(42, 49), 11, 4.5) as fail;  -- range type doesn't fit

drop function f1(x anycompatiblerange, y anycompatible, z anycompatible);
---END---
---START---

-- fail, can't infer type:
create function f1(x anycompatible) returns anycompatiblerange as $$
begin
  return array[x + 1, x + 2];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

create function f1(x anycompatiblerange, y anycompatiblearray) returns anycompatiblerange as $$
begin
  return x;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(int4range(42, 49), array[11]) as int, f1(float8range(4.5, 7.8), array[7]) as num;
---END---
---START---

drop function f1(x anycompatiblerange, y anycompatiblearray);
---END---
---START---

create function f1(a anyelement, b anyarray,
                   c anycompatible, d anycompatible,
                   OUT x anyarray, OUT y anycompatiblearray)
as $$
begin
  x := a || b;
---END---
---START---
  y := array[c, d];
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select x, pg_typeof(x), y, pg_typeof(y)
  from f1(11, array[1, 2], 42, 34.5);
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from f1(11, array[1, 2], point(1,2), point(3,4));
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from f1(11, '{1,2}', point(1,2), '(3,4)');
---END---
---START---
select x, pg_typeof(x), y, pg_typeof(y)
  from f1(11, array[1, 2.2], 42, 34.5);  -- fail

drop function f1(a anyelement, b anyarray,
                 c anycompatible, d anycompatible);
---END---
---START---

--
-- Test handling of OUT parameters, including polymorphic cases.
-- Note that RETURN is optional with OUT params; we try both ways.
--

-- wrong way to do it:
create function f1(in i int, out j int) returns int as $$
begin
  return i+1;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

create function f1(in i int, out j int) as $$
begin
  j := i+1;
---END---
---START---
  return;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(42);
---END---
---START---
select * from f1(42);
---END---
---START---

create or replace function f1(inout i int) as $$
begin
  i := i+1;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(42);
---END---
---START---
select * from f1(42);
---END---
---START---

drop function f1(int);
---END---
---START---

create function f1(in i int, out j int) returns setof int as $$
begin
  j := i+1;
---END---
---START---
  return next;
---END---
---START---
  j := i+2;
---END---
---START---
  return next;
---END---
---START---
  return;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select * from f1(42);
---END---
---START---

drop function f1(int);
---END---
---START---

create function f1(in i int, out j int, out k text) as $$
begin
  j := i;
---END---
---START---
  j := j+1;
---END---
---START---
  k := 'foo';
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select f1(42);
---END---
---START---
select * from f1(42);
---END---
---START---

drop function f1(int);
---END---
---START---

create function f1(in i int, out j int, out k text) returns setof record as $$
begin
  j := i+1;
---END---
---START---
  k := 'foo';
---END---
---START---
  return next;
---END---
---START---
  j := j+1;
---END---
---START---
  k := 'foot';
---END---
---START---
  return next;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select * from f1(42);
---END---
---START---

drop function f1(int);
---END---
---START---

create function duplic(in i anyelement, out j anyelement, out k anyarray) as $$
begin
  j := i;
---END---
---START---
  k := array[j,j];
---END---
---START---
  return;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select * from duplic(42);
---END---
---START---
select * from duplic('foo'::text);
---END---
---START---

drop function duplic(anyelement);
---END---
---START---

create function duplic(in i anycompatiblerange, out j anycompatible, out k anycompatiblearray) as $$
begin
  j := lower(i);
---END---
---START---
  k := array[lower(i),upper(i)];
---END---
---START---
  return;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select * from duplic(int4range(42,49));
---END---
---START---
select * from duplic(textrange('aaa', 'bbb'));
---END---
---START---

drop function duplic(anycompatiblerange);
---END---
---START---

--
-- test PERFORM
--

create table perform_test (
	a	INT,
	b	INT
);
---END---
---START---

create function perform_simple_func(int) returns boolean as '
BEGIN
	IF $1 < 20 THEN
		INSERT INTO perform_test VALUES ($1, $1 + 10);
---END---
---START---
		RETURN TRUE;
---END---
---START---
	ELSE
		RETURN FALSE;
---END---
---START---
	END IF;
---END---
---START---
END;' language plpgsql;
---END---
---START---

create function perform_test_func() returns void as '
BEGIN
	IF FOUND then
		INSERT INTO perform_test VALUES (100, 100);
---END---
---START---
	END IF;
---END---
---START---

	PERFORM perform_simple_func(5);
---END---
---START---

	IF FOUND then
		INSERT INTO perform_test VALUES (100, 100);
---END---
---START---
	END IF;
---END---
---START---

	PERFORM perform_simple_func(50);
---END---
---START---

	IF FOUND then
		INSERT INTO perform_test VALUES (100, 100);
---END---
---START---
	END IF;
---END---
---START---

	RETURN;
---END---
---START---
END;' language plpgsql;
---END---
---START---

SELECT perform_test_func();
---END---
---START---
SELECT * FROM perform_test;
---END---
---START---

drop table perform_test;
---END---
---START---

--
-- Test proper snapshot handling in simple expressions
--

create temp table users(login text, id serial);
---END---
---START---

create function sp_id_user(a_login text) returns int as $$
declare x int;
---END---
---START---
begin
  select into x id from users where login = a_login;
---END---
---START---
  if found then return x; end if;
---END---
---START---
  return 0;
---END---
---START---
end$$ language plpgsql stable;
---END---
---START---

insert into users values('user1');
---END---
---START---

select sp_id_user('user1');
---END---
---START---
select sp_id_user('userx');
---END---
---START---

create function sp_add_user(a_login text) returns int as $$
declare my_id_user int;
---END---
---START---
begin
  my_id_user = sp_id_user( a_login );
---END---
---START---
  IF  my_id_user > 0 THEN
    RETURN -1;  -- error code for existing user
  END IF;
---END---
---START---
  INSERT INTO users ( login ) VALUES ( a_login );
---END---
---START---
  my_id_user = sp_id_user( a_login );
---END---
---START---
  IF  my_id_user = 0 THEN
    RETURN -2;  -- error code for insertion failure
  END IF;
---END---
---START---
  RETURN my_id_user;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select sp_add_user('user1');
---END---
---START---
select sp_add_user('user2');
---END---
---START---
select sp_add_user('user2');
---END---
---START---
select sp_add_user('user3');
---END---
---START---
select sp_add_user('user3');
---END---
---START---

drop function sp_add_user(text);
---END---
---START---
drop function sp_id_user(text);
---END---
---START---

--
-- tests for refcursors
--
create table rc_test (a int, b int);
---END---
---START---
copy rc_test from stdin;
---END---
---START---
5	10
50	100
500	1000
\.

create function return_unnamed_refcursor() returns refcursor as $$
declare
    rc refcursor;
---END---
---START---
begin
    open rc for select a from rc_test;
---END---
---START---
    return rc;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create function use_refcursor(rc refcursor) returns int as $$
declare
    rc refcursor;
---END---
---START---
    x record;
---END---
---START---
begin
    rc := return_unnamed_refcursor();
---END---
---START---
    fetch next from rc into x;
---END---
---START---
    return x.a;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select use_refcursor(return_unnamed_refcursor());
---END---
---START---

create function return_refcursor(rc refcursor) returns refcursor as $$
begin
    open rc for select a from rc_test;
---END---
---START---
    return rc;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

create function refcursor_test1(refcursor) returns refcursor as $$
begin
    perform return_refcursor($1);
---END---
---START---
    return $1;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

begin;
---END---
---START---

select refcursor_test1('test1');
---END---
---START---
fetch next in test1;
---END---
---START---

select refcursor_test1('test2');
---END---
---START---
fetch all from test2;
---END---
---START---

commit;
---END---
---START---

-- should fail
fetch next from test1;
---END---
---START---

create function refcursor_test2(int, int) returns boolean as $$
declare
    c1 cursor (param1 int, param2 int) for select * from rc_test where a > param1 and b > param2;
---END---
---START---
    nonsense record;
---END---
---START---
begin
    open c1($1, $2);
---END---
---START---
    fetch c1 into nonsense;
---END---
---START---
    close c1;
---END---
---START---
    if found then
        return true;
---END---
---START---
    else
        return false;
---END---
---START---
    end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select refcursor_test2(20000, 20000) as "Should be false",
       refcursor_test2(20, 20) as "Should be true";
---END---
---START---

-- should fail
create function constant_refcursor() returns refcursor as $$
declare
    rc constant refcursor;
---END---
---START---
begin
    open rc for select a from rc_test;
---END---
---START---
    return rc;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select constant_refcursor();
---END---
---START---

-- but it's okay like this
create or replace function constant_refcursor() returns refcursor as $$
declare
    rc constant refcursor := 'my_cursor_name';
---END---
---START---
begin
    open rc for select a from rc_test;
---END---
---START---
    return rc;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select constant_refcursor();
---END---
---START---

--
-- tests for cursors with named parameter arguments
--
create function namedparmcursor_test1(int, int) returns boolean as $$
declare
    c1 cursor (param1 int, param12 int) for select * from rc_test where a > param1 and b > param12;
---END---
---START---
    nonsense record;
---END---
---START---
begin
    open c1(param12 := $2, param1 := $1);
---END---
---START---
    fetch c1 into nonsense;
---END---
---START---
    close c1;
---END---
---START---
    if found then
        return true;
---END---
---START---
    else
        return false;
---END---
---START---
    end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select namedparmcursor_test1(20000, 20000) as "Should be false",
       namedparmcursor_test1(20, 20) as "Should be true";
---END---
---START---

-- mixing named and positional argument notations
create function namedparmcursor_test2(int, int) returns boolean as $$
declare
    c1 cursor (param1 int, param2 int) for select * from rc_test where a > param1 and b > param2;
---END---
---START---
    nonsense record;
---END---
---START---
begin
    open c1(param1 := $1, $2);
---END---
---START---
    fetch c1 into nonsense;
---END---
---START---
    close c1;
---END---
---START---
    if found then
        return true;
---END---
---START---
    else
        return false;
---END---
---START---
    end if;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---
select namedparmcursor_test2(20, 20);
---END---
---START---

-- mixing named and positional: param2 is given twice, once in named notation
-- and second time in positional notation. Should throw an error at parse time
create function namedparmcursor_test3() returns void as $$
declare
    c1 cursor (param1 int, param2 int) for select * from rc_test where a > param1 and b > param2;
---END---
---START---
begin
    open c1(param2 := 20, 21);
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

-- mixing named and positional: same as previous test, but param1 is duplicated
create function namedparmcursor_test4() returns void as $$
declare
    c1 cursor (param1 int, param2 int) for select * from rc_test where a > param1 and b > param2;
---END---
---START---
begin
    open c1(20, param1 := 21);
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

-- duplicate named parameter, should throw an error at parse time
create function namedparmcursor_test5() returns void as $$
declare
  c1 cursor (p1 int, p2 int) for
    select * from tenk1 where thousand = p1 and tenthous = p2;
---END---
---START---
begin
  open c1 (p2 := 77, p2 := 42);
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

-- not enough parameters, should throw an error at parse time
create function namedparmcursor_test6() returns void as $$
declare
  c1 cursor (p1 int, p2 int) for
    select * from tenk1 where thousand = p1 and tenthous = p2;
---END---
---START---
begin
  open c1 (p2 := 77);
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

-- division by zero runtime error, the context given in the error message
-- should be sensible
create function namedparmcursor_test7() returns void as $$
declare
  c1 cursor (p1 int, p2 int) for
    select * from tenk1 where thousand = p1 and tenthous = p2;
---END---
---START---
begin
  open c1 (p2 := 77, p1 := 42/0);
---END---
---START---
end $$ language plpgsql;
---END---
---START---
select namedparmcursor_test7();
---END---
---START---

-- check that line comments work correctly within the argument list (there
-- is some special handling of this case in the code: the newline after the
-- comment must be preserved when the argument-evaluating query is
-- constructed, otherwise the comment effectively comments out the next
-- argument, too)
create function namedparmcursor_test8() returns int4 as $$
declare
  c1 cursor (p1 int, p2 int) for
    select count(*) from tenk1 where thousand = p1 and tenthous = p2;
---END---
---START---
  n int4;
---END---
---START---
begin
  open c1 (77 -- test
  , 42);
---END---
---START---
  fetch c1 into n;
---END---
---START---
  return n;
---END---
---START---
end $$ language plpgsql;
---END---
---START---
select namedparmcursor_test8();
---END---
---START---

-- cursor parameter name can match plpgsql variable or unreserved keyword
create function namedparmcursor_test9(p1 int) returns int4 as $$
declare
  c1 cursor (p1 int, p2 int, debug int) for
    select count(*) from tenk1 where thousand = p1 and tenthous = p2
      and four = debug;
---END---
---START---
  p2 int4 := 1006;
---END---
---START---
  n int4;
---END---
---START---
begin
  open c1 (p1 := p1, p2 := p2, debug := 2);
---END---
---START---
  fetch c1 into n;
---END---
---START---
  return n;
---END---
---START---
end $$ language plpgsql;
---END---
---START---
select namedparmcursor_test9(6);
---END---
---START---

--
-- tests for "raise" processing
--
create function raise_test1(int) returns int as $$
begin
    raise notice 'This message has too many parameters!', $1;
---END---
---START---
    return $1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create function raise_test2(int) returns int as $$
begin
    raise notice 'This message has too few parameters: %, %, %', $1, $1;
---END---
---START---
    return $1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create function raise_test3(int) returns int as $$
begin
    raise notice 'This message has no parameters (despite having %% signs in it)!';
---END---
---START---
    return $1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test3(1);
---END---
---START---

-- Test re-RAISE inside a nested exception block.  This case is allowed
-- by Oracle's PL/SQL but was handled differently by PG before 9.1.

CREATE FUNCTION reraise_test() RETURNS void AS $$
BEGIN
   BEGIN
       RAISE syntax_error;
---END---
---START---
   EXCEPTION
       WHEN syntax_error THEN
           BEGIN
               raise notice 'exception % thrown in inner block, reraising', sqlerrm;
---END---
---START---
               RAISE;
---END---
---START---
           EXCEPTION
               WHEN OTHERS THEN
                   raise notice 'RIGHT - exception % caught in inner block', sqlerrm;
---END---
---START---
           END;
---END---
---START---
   END;
---END---
---START---
EXCEPTION
   WHEN OTHERS THEN
       raise notice 'WRONG - exception % caught in outer block', sqlerrm;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

SELECT reraise_test();
---END---
---START---

--
-- reject function definitions that contain malformed SQL queries at
-- compile-time, where possible
--
create function bad_sql1() returns int as $$
declare a int;
---END---
---START---
begin
    a := 5;
---END---
---START---
    Johnny Yuma;
---END---
---START---
    a := 10;
---END---
---START---
    return a;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

create function bad_sql2() returns int as $$
declare r record;
---END---
---START---
begin
    for r in select I fought the law, the law won LOOP
        raise notice 'in loop';
---END---
---START---
    end loop;
---END---
---START---
    return 5;
---END---
---START---
end;$$ language plpgsql;
---END---
---START---

-- a RETURN expression is mandatory, except for void-returning
-- functions, where it is not allowed
create function missing_return_expr() returns int as $$
begin
    return ;
---END---
---START---
end;$$ language plpgsql;
---END---
---START---

create function void_return_expr() returns void as $$
begin
    return 5;
---END---
---START---
end;$$ language plpgsql;
---END---
---START---

-- VOID functions are allowed to omit RETURN
create function void_return_expr() returns void as $$
begin
    perform 2+2;
---END---
---START---
end;$$ language plpgsql;
---END---
---START---

select void_return_expr();
---END---
---START---

-- but ordinary functions are not
create function missing_return_expr() returns int as $$
begin
    perform 2+2;
---END---
---START---
end;$$ language plpgsql;
---END---
---START---

select missing_return_expr();
---END---
---START---

drop function void_return_expr();
---END---
---START---
drop function missing_return_expr();
---END---
---START---

--
-- EXECUTE ... INTO test
--

create table eifoo (i integer, y integer);
---END---
---START---
create type eitype as (i integer, y integer);
---END---
---START---

create or replace function execute_into_test(varchar) returns record as $$
declare
    _r record;
---END---
---START---
    _rt eifoo%rowtype;
---END---
---START---
    _v eitype;
---END---
---START---
    i int;
---END---
---START---
    j int;
---END---
---START---
    k int;
---END---
---START---
begin
    execute 'insert into '||$1||' values(10,15)';
---END---
---START---
    execute 'select (row).* from (select row(10,1)::eifoo) s' into _r;
---END---
---START---
    raise notice '% %', _r.i, _r.y;
---END---
---START---
    execute 'select * from '||$1||' limit 1' into _rt;
---END---
---START---
    raise notice '% %', _rt.i, _rt.y;
---END---
---START---
    execute 'select *, 20 from '||$1||' limit 1' into i, j, k;
---END---
---START---
    raise notice '% % %', i, j, k;
---END---
---START---
    execute 'select 1,2' into _v;
---END---
---START---
    return _v;
---END---
---START---
end; $$ language plpgsql;
---END---
---START---

select execute_into_test('eifoo');
---END---
---START---

drop table eifoo cascade;
---END---
---START---
drop type eitype cascade;
---END---
---START---

--
-- SQLSTATE and SQLERRM test
--

create function excpt_test1() returns void as $$
begin
    raise notice '% %', sqlstate, sqlerrm;
---END---
---START---
end; $$ language plpgsql;
---END---
---START---
-- should fail: SQLSTATE and SQLERRM are only in defined EXCEPTION
-- blocks
select excpt_test1();
---END---
---START---

create function excpt_test2() returns void as $$
begin
    begin
        begin
            raise notice '% %', sqlstate, sqlerrm;
---END---
---START---
        end;
---END---
---START---
    end;
---END---
---START---
end; $$ language plpgsql;
---END---
---START---
-- should fail
select excpt_test2();
---END---
---START---

create function excpt_test3() returns void as $$
begin
    begin
        raise exception 'user exception';
---END---
---START---
    exception when others then
	    raise notice 'caught exception % %', sqlstate, sqlerrm;
---END---
---START---
	    begin
	        raise notice '% %', sqlstate, sqlerrm;
---END---
---START---
	        perform 10/0;
---END---
---START---
        exception
            when substring_error then
                -- this exception handler shouldn't be invoked
                raise notice 'unexpected exception: % %', sqlstate, sqlerrm;
---END---
---START---
	        when division_by_zero then
	            raise notice 'caught exception % %', sqlstate, sqlerrm;
---END---
---START---
	    end;
---END---
---START---
	    raise notice '% %', sqlstate, sqlerrm;
---END---
---START---
    end;
---END---
---START---
end; $$ language plpgsql;
---END---
---START---
select excpt_test3();
---END---
---START---

create function excpt_test4() returns text as $$
begin
	begin perform 1/0;
---END---
---START---
	exception when others then return sqlerrm; end;
---END---
---START---
end; $$ language plpgsql;
---END---
---START---
select excpt_test4();
---END---
---START---

drop function excpt_test1();
---END---
---START---
drop function excpt_test2();
---END---
---START---
drop function excpt_test3();
---END---
---START---
drop function excpt_test4();
---END---
---START---

-- parameters of raise stmt can be expressions
create function raise_exprs() returns void as $$
declare
    a integer[] = '{10,20,30}';
---END---
---START---
    c varchar = 'xyz';
---END---
---START---
    i integer;
---END---
---START---
begin
    i := 2;
---END---
---START---
    raise notice '%; %; %; %; %; %', a, a[i], c, (select c || 'abc'), row(10,'aaa',NULL,30), NULL;
---END---
---START---
end;$$ language plpgsql;
---END---
---START---

select raise_exprs();
---END---
---START---
drop function raise_exprs();
---END---
---START---

-- regression test: verify that multiple uses of same plpgsql datum within
-- a SQL command all get mapped to the same $n parameter.  The return value
-- of the SELECT is not important, we only care that it doesn't fail with
-- a complaint about an ungrouped column reference.
create function multi_datum_use(p1 int) returns bool as $$
declare
  x int;
---END---
---START---
  y int;
---END---
---START---
begin
  select into x,y unique1/p1, unique1/$1 from tenk1 group by unique1/p1;
---END---
---START---
  return x = y;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select multi_datum_use(42);
---END---
---START---

--
-- Test STRICT limiter in both planned and EXECUTE invocations.
-- Note that a data-modifying query is quasi strict (disallow multi rows)
-- by default in the planned case, but not in EXECUTE.
--

create temp table foo (f1 int, f2 int);
---END---
---START---

insert into foo values (1,2), (3,4);
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should work
  insert into foo values(5,6) returning * into x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should fail due to implicit strict
  insert into foo values(7,8),(9,10) returning * into x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should work
  execute 'insert into foo values(5,6) returning *' into x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- this should work since EXECUTE isn't as picky
  execute 'insert into foo values(7,8),(9,10) returning *' into x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

select * from foo;
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should work
  select * from foo where f1 = 3 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should fail, no rows
  select * from foo where f1 = 0 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should fail, too many rows
  select * from foo where f1 > 3 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should work
  execute 'select * from foo where f1 = 3' into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should fail, no rows
  execute 'select * from foo where f1 = 0' into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- should fail, too many rows
  execute 'select * from foo where f1 > 3' into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

drop function stricttest();
---END---
---START---

-- test printing parameters after failure due to STRICT

set plpgsql.print_strict_params to true;
---END---
---START---

create or replace function stricttest() returns void as $$
declare
x record;
---END---
---START---
p1 int := 2;
---END---
---START---
p3 text := 'foo';
---END---
---START---
begin
  -- no rows
  select * from foo where f1 = p1 and f1::text = p3 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare
x record;
---END---
---START---
p1 int := 2;
---END---
---START---
p3 text := $a$'Valame Dios!' dijo Sancho; 'no le dije yo a vuestra merced que mirase bien lo que hacia?'$a$;
---END---
---START---
begin
  -- no rows
  select * from foo where f1 = p1 and f1::text = p3 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare
x record;
---END---
---START---
p1 int := 2;
---END---
---START---
p3 text := 'foo';
---END---
---START---
begin
  -- too many rows
  select * from foo where f1 > p1 or f1::text = p3  into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- too many rows, no params
  select * from foo where f1 > 3 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- no rows
  execute 'select * from foo where f1 = $1 or f1::text = $2' using 0, 'foo' into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- too many rows
  execute 'select * from foo where f1 > $1' using 1 into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
declare x record;
---END---
---START---
begin
  -- too many rows, no parameters
  execute 'select * from foo where f1 > 3' into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

create or replace function stricttest() returns void as $$
-- override the global
#print_strict_params off
declare
x record;
---END---
---START---
p1 int := 2;
---END---
---START---
p3 text := 'foo';
---END---
---START---
begin
  -- too many rows
  select * from foo where f1 > p1 or f1::text = p3  into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

reset plpgsql.print_strict_params;
---END---
---START---

create or replace function stricttest() returns void as $$
-- override the global
#print_strict_params on
declare
x record;
---END---
---START---
p1 int := 2;
---END---
---START---
p3 text := 'foo';
---END---
---START---
begin
  -- too many rows
  select * from foo where f1 > p1 or f1::text = p3  into strict x;
---END---
---START---
  raise notice 'x.f1 = %, x.f2 = %', x.f1, x.f2;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select stricttest();
---END---
---START---

-- test warnings and errors
set plpgsql.extra_warnings to 'all';
---END---
---START---
set plpgsql.extra_warnings to 'none';
---END---
---START---
set plpgsql.extra_errors to 'all';
---END---
---START---
set plpgsql.extra_errors to 'none';
---END---
---START---

-- test warnings when shadowing a variable

set plpgsql.extra_warnings to 'shadowed_variables';
---END---
---START---

-- simple shadowing of input and output parameters
create or replace function shadowtest(in1 int)
	returns table (out1 int) as $$
declare
in1 int;
---END---
---START---
out1 int;
---END---
---START---
begin
end
$$ language plpgsql;
---END---
---START---
select shadowtest(1);
---END---
---START---

set plpgsql.extra_warnings to 'shadowed_variables';
---END---
---START---
select shadowtest(1);
---END---
---START---
create or replace function shadowtest(in1 int)
	returns table (out1 int) as $$
declare
in1 int;
---END---
---START---
out1 int;
---END---
---START---
begin
end
$$ language plpgsql;
---END---
---START---
select shadowtest(1);
---END---
---START---
drop function shadowtest(int);
---END---
---START---

-- shadowing in a second DECLARE block
create or replace function shadowtest()
	returns void as $$
declare
f1 int;
---END---
---START---
begin
	declare
	f1 int;
---END---
---START---
	begin
	end;
---END---
---START---
end$$ language plpgsql;
---END---
---START---
drop function shadowtest();
---END---
---START---

-- several levels of shadowing
create or replace function shadowtest(in1 int)
	returns void as $$
declare
in1 int;
---END---
---START---
begin
	declare
	in1 int;
---END---
---START---
	begin
	end;
---END---
---START---
end$$ language plpgsql;
---END---
---START---
drop function shadowtest(int);
---END---
---START---

-- shadowing in cursor definitions
create or replace function shadowtest()
	returns void as $$
declare
f1 int;
---END---
---START---
c1 cursor (f1 int) for select 1;
---END---
---START---
begin
end$$ language plpgsql;
---END---
---START---
drop function shadowtest();
---END---
---START---

-- test errors when shadowing a variable

set plpgsql.extra_errors to 'shadowed_variables';
---END---
---START---

create or replace function shadowtest(f1 int)
	returns boolean as $$
declare f1 int; begin return 1; end $$ language plpgsql;
---END---
---START---

select shadowtest(1);
---END---
---START---

reset plpgsql.extra_errors;
---END---
---START---
reset plpgsql.extra_warnings;
---END---
---START---

create or replace function shadowtest(f1 int)
	returns boolean as $$
declare f1 int; begin return 1; end $$ language plpgsql;
---END---
---START---

select shadowtest(1);
---END---
---START---

-- runtime extra checks
set plpgsql.extra_warnings to 'too_many_rows';
---END---
---START---

do $$
declare x int;
---END---
---START---
begin
  select v from generate_series(1,2) g(v) into x;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

set plpgsql.extra_errors to 'too_many_rows';
---END---
---START---

do $$
declare x int;
---END---
---START---
begin
  select v from generate_series(1,2) g(v) into x;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

reset plpgsql.extra_errors;
---END---
---START---
reset plpgsql.extra_warnings;
---END---
---START---

set plpgsql.extra_warnings to 'strict_multi_assignment';
---END---
---START---

do $$
declare
  x int;
---END---
---START---
  y int;
---END---
---START---
begin
  select 1 into x, y;
---END---
---START---
  select 1,2 into x, y;
---END---
---START---
  select 1,2,3 into x, y;
---END---
---START---
end
$$;
---END---
---START---

set plpgsql.extra_errors to 'strict_multi_assignment';
---END---
---START---

do $$
declare
  x int;
---END---
---START---
  y int;
---END---
---START---
begin
  select 1 into x, y;
---END---
---START---
  select 1,2 into x, y;
---END---
---START---
  select 1,2,3 into x, y;
---END---
---START---
end
$$;
---END---
---START---

create table test_01(a int, b int, c int);
---END---
---START---

alter table test_01 drop column a;
---END---
---START---

-- the check is active only when source table is not empty
insert into test_01 values(10,20);
---END---
---START---

do $$
declare
  x int;
---END---
---START---
  y int;
---END---
---START---
begin
  select * from test_01 into x, y; -- should be ok
  raise notice 'ok';
---END---
---START---
  select * from test_01 into x;    -- should to fail
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare
  t test_01;
---END---
---START---
begin
  select 1, 2 into t;  -- should be ok
  raise notice 'ok';
---END---
---START---
  select 1, 2, 3 into t; -- should fail;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare
  t test_01;
---END---
---START---
begin
  select 1 into t; -- should fail;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

drop table test_01;
---END---
---START---

reset plpgsql.extra_errors;
---END---
---START---
reset plpgsql.extra_warnings;
---END---
---START---

-- test scrollable cursor support

create function sc_test() returns setof integer as $$
declare
  c scroll cursor for select f1 from int4_tbl;
---END---
---START---
  x integer;
---END---
---START---
begin
  open c;
---END---
---START---
  fetch last from c into x;
---END---
---START---
  while found loop
    return next x;
---END---
---START---
    fetch prior from c into x;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();
---END---
---START---

create or replace function sc_test() returns setof integer as $$
declare
  c no scroll cursor for select f1 from int4_tbl;
---END---
---START---
  x integer;
---END---
---START---
begin
  open c;
---END---
---START---
  fetch last from c into x;
---END---
---START---
  while found loop
    return next x;
---END---
---START---
    fetch prior from c into x;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();  -- fails because of NO SCROLL specification

create or replace function sc_test() returns setof integer as $$
declare
  c refcursor;
---END---
---START---
  x integer;
---END---
---START---
begin
  open c scroll for select f1 from int4_tbl;
---END---
---START---
  fetch last from c into x;
---END---
---START---
  while found loop
    return next x;
---END---
---START---
    fetch prior from c into x;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();
---END---
---START---

create or replace function sc_test() returns setof integer as $$
declare
  c refcursor;
---END---
---START---
  x integer;
---END---
---START---
begin
  open c scroll for execute 'select f1 from int4_tbl';
---END---
---START---
  fetch last from c into x;
---END---
---START---
  while found loop
    return next x;
---END---
---START---
    fetch relative -2 from c into x;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();
---END---
---START---

create or replace function sc_test() returns setof integer as $$
declare
  c refcursor;
---END---
---START---
  x integer;
---END---
---START---
begin
  open c scroll for execute 'select f1 from int4_tbl';
---END---
---START---
  fetch last from c into x;
---END---
---START---
  while found loop
    return next x;
---END---
---START---
    move backward 2 from c;
---END---
---START---
    fetch relative -1 from c into x;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();
---END---
---START---

create or replace function sc_test() returns setof integer as $$
declare
  c cursor for select * from generate_series(1, 10);
---END---
---START---
  x integer;
---END---
---START---
begin
  open c;
---END---
---START---
  loop
      move relative 2 in c;
---END---
---START---
      if not found then
          exit;
---END---
---START---
      end if;
---END---
---START---
      fetch next from c into x;
---END---
---START---
      if found then
          return next x;
---END---
---START---
      end if;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();
---END---
---START---

create or replace function sc_test() returns setof integer as $$
declare
  c cursor for select * from generate_series(1, 10);
---END---
---START---
  x integer;
---END---
---START---
begin
  open c;
---END---
---START---
  move forward all in c;
---END---
---START---
  fetch backward from c into x;
---END---
---START---
  if found then
    return next x;
---END---
---START---
  end if;
---END---
---START---
  close c;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from sc_test();
---END---
---START---

drop function sc_test();
---END---
---START---

-- test qualified variable names

create function pl_qual_names (param1 int) returns void as $$
<<outerblock>>
declare
  param1 int := 1;
---END---
---START---
begin
  <<innerblock>>
  declare
    param1 int := 2;
---END---
---START---
  begin
    raise notice 'param1 = %', param1;
---END---
---START---
    raise notice 'pl_qual_names.param1 = %', pl_qual_names.param1;
---END---
---START---
    raise notice 'outerblock.param1 = %', outerblock.param1;
---END---
---START---
    raise notice 'innerblock.param1 = %', innerblock.param1;
---END---
---START---
  end;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select pl_qual_names(42);
---END---
---START---

drop function pl_qual_names(int);
---END---
---START---

-- tests for RETURN QUERY
create function ret_query1(out int, out int) returns setof record as $$
begin
    $1 := -1;
---END---
---START---
    $2 := -2;
---END---
---START---
    return next;
---END---
---START---
    return query select x + 1, x * 10 from generate_series(0, 10) s (x);
---END---
---START---
    return next;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from ret_query1();
---END---
---START---

create type record_type as (x text, y int, z boolean);
---END---
---START---

create or replace function ret_query2(lim int) returns setof record_type as $$
begin
    return query select fipshash(s.x::text), s.x, s.x > 0
                 from generate_series(-8, lim) s (x) where s.x % 2 = 0;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from ret_query2(8);
---END---
---START---

-- test EXECUTE USING
create function exc_using(int, text) returns int as $$
declare i int;
---END---
---START---
begin
  for i in execute 'select * from generate_series(1,$1)' using $1+1 loop
    raise notice '%', i;
---END---
---START---
  end loop;
---END---
---START---
  execute 'select $2 + $2*3 + length($1)' into i using $2,$1;
---END---
---START---
  return i;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select exc_using(5, 'foobar');
---END---
---START---

drop function exc_using(int, text);
---END---
---START---

create or replace function exc_using(int) returns void as $$
declare
  c refcursor;
---END---
---START---
  i int;
---END---
---START---
begin
  open c for execute 'select * from generate_series(1,$1)' using $1+1;
---END---
---START---
  loop
    fetch c into i;
---END---
---START---
    exit when not found;
---END---
---START---
    raise notice '%', i;
---END---
---START---
  end loop;
---END---
---START---
  close c;
---END---
---START---
  return;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select exc_using(5);
---END---
---START---

drop function exc_using(int);
---END---
---START---

-- test FOR-over-cursor

create or replace function forc01() returns void as $$
declare
  c cursor(r1 integer, r2 integer)
       for select * from generate_series(r1,r2) i;
---END---
---START---
  c2 cursor
       for select * from generate_series(41,43) i;
---END---
---START---
begin
  -- assign portal names to cursors to get stable output
  c := 'c';
---END---
---START---
  c2 := 'c2';
---END---
---START---
  for r in c(5,7) loop
    raise notice '% from %', r.i, c;
---END---
---START---
  end loop;
---END---
---START---
  -- again, to test if cursor was closed properly
  for r in c(9,10) loop
    raise notice '% from %', r.i, c;
---END---
---START---
  end loop;
---END---
---START---
  -- and test a parameterless cursor
  for r in c2 loop
    raise notice '% from %', r.i, c2;
---END---
---START---
  end loop;
---END---
---START---
  -- and try it with a hand-assigned name
  raise notice 'after loop, c2 = %', c2;
---END---
---START---
  c2 := 'special_name';
---END---
---START---
  for r in c2 loop
    raise notice '% from %', r.i, c2;
---END---
---START---
  end loop;
---END---
---START---
  raise notice 'after loop, c2 = %', c2;
---END---
---START---
  -- and try it with a generated name
  -- (which we can't show in the output because it's variable)
  c2 := null;
---END---
---START---
  for r in c2 loop
    raise notice '%', r.i;
---END---
---START---
  end loop;
---END---
---START---
  raise notice 'after loop, c2 = %', c2;
---END---
---START---
  return;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select forc01();
---END---
---START---

-- try updating the cursor's current row

create temp table forc_test as
  select n as i, n as j from generate_series(1,10) n;
---END---
---START---

create or replace function forc01() returns void as $$
declare
  c cursor for select * from forc_test;
---END---
---START---
begin
  for r in c loop
    raise notice '%, %', r.i, r.j;
---END---
---START---
    update forc_test set i = i * 100, j = r.j * 2 where current of c;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select forc01();
---END---
---START---

select * from forc_test;
---END---
---START---

-- same, with a cursor whose portal name doesn't match variable name
create or replace function forc01() returns void as $$
declare
  c refcursor := 'fooled_ya';
---END---
---START---
  r record;
---END---
---START---
begin
  open c for select * from forc_test;
---END---
---START---
  loop
    fetch c into r;
---END---
---START---
    exit when not found;
---END---
---START---
    raise notice '%, %', r.i, r.j;
---END---
---START---
    update forc_test set i = i * 100, j = r.j * 2 where current of c;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select forc01();
---END---
---START---

select * from forc_test;
---END---
---START---

drop function forc01();
---END---
---START---

-- it's okay to re-use a cursor variable name, even when bound

do $$
declare cnt int := 0;
---END---
---START---
  c1 cursor for select * from forc_test;
---END---
---START---
begin
  for r1 in c1 loop
    declare c1 cursor for select * from forc_test;
---END---
---START---
    begin
      for r2 in c1 loop
        cnt := cnt + 1;
---END---
---START---
      end loop;
---END---
---START---
    end;
---END---
---START---
  end loop;
---END---
---START---
  raise notice 'cnt = %', cnt;
---END---
---START---
end $$;
---END---
---START---

-- fail because cursor has no query bound to it

create or replace function forc_bad() returns void as $$
declare
  c refcursor;
---END---
---START---
begin
  for r in c loop
    raise notice '%', r.i;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

-- test RETURN QUERY EXECUTE

create or replace function return_dquery()
returns setof int as $$
begin
  return query execute 'select * from (values(10),(20)) f';
---END---
---START---
  return query execute 'select * from (values($1),($2)) f' using 40,50;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from return_dquery();
---END---
---START---

drop function return_dquery();
---END---
---START---

-- test RETURN QUERY with dropped columns

create table tabwithcols(a int, b int, c int, d int);
---END---
---START---
insert into tabwithcols values(10,20,30,40),(50,60,70,80);
---END---
---START---

create or replace function returnqueryf()
returns setof tabwithcols as $$
begin
  return query select * from tabwithcols;
---END---
---START---
  return query execute 'select * from tabwithcols';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from returnqueryf();
---END---
---START---

alter table tabwithcols drop column b;
---END---
---START---

select * from returnqueryf();
---END---
---START---

alter table tabwithcols drop column d;
---END---
---START---

select * from returnqueryf();
---END---
---START---

alter table tabwithcols add column d int;
---END---
---START---

select * from returnqueryf();
---END---
---START---

drop function returnqueryf();
---END---
---START---
drop table tabwithcols;
---END---
---START---

--
-- Tests for composite-type results
--

create type compostype as (x int, y varchar);
---END---
---START---

-- test: use of variable of composite type in return statement
create or replace function compos() returns compostype as $$
declare
  v compostype;
---END---
---START---
begin
  v := (1, 'hello');
---END---
---START---
  return v;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

-- test: use of variable of record type in return statement
create or replace function compos() returns compostype as $$
declare
  v record;
---END---
---START---
begin
  v := (1, 'hello'::varchar);
---END---
---START---
  return v;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

-- test: use of row expr in return statement
create or replace function compos() returns compostype as $$
begin
  return (1, 'hello'::varchar);
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

-- this does not work currently (no implicit casting)
create or replace function compos() returns compostype as $$
begin
  return (1, 'hello');
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

-- ... but this does
create or replace function compos() returns compostype as $$
begin
  return (1, 'hello')::compostype;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

drop function compos();
---END---
---START---

-- test: return a row expr as record.
create or replace function composrec() returns record as $$
declare
  v record;
---END---
---START---
begin
  v := (1, 'hello');
---END---
---START---
  return v;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select composrec();
---END---
---START---

-- test: return row expr in return statement.
create or replace function composrec() returns record as $$
begin
  return (1, 'hello');
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select composrec();
---END---
---START---

drop function composrec();
---END---
---START---

-- test: row expr in RETURN NEXT statement.
create or replace function compos() returns setof compostype as $$
begin
  for i in 1..3
  loop
    return next (1, 'hello'::varchar);
---END---
---START---
  end loop;
---END---
---START---
  return next null::compostype;
---END---
---START---
  return next (2, 'goodbye')::compostype;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from compos();
---END---
---START---

drop function compos();
---END---
---START---

-- test: use invalid expr in return statement.
create or replace function compos() returns compostype as $$
begin
  return 1 + 1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

-- RETURN variable is a different code path ...
create or replace function compos() returns compostype as $$
declare x int := 42;
---END---
---START---
begin
  return x;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from compos();
---END---
---START---

drop function compos();
---END---
---START---

-- test: invalid use of composite variable in scalar-returning function
create or replace function compos() returns int as $$
declare
  v compostype;
---END---
---START---
begin
  v := (1, 'hello');
---END---
---START---
  return v;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

-- test: invalid use of composite expression in scalar-returning function
create or replace function compos() returns int as $$
begin
  return (1, 'hello')::compostype;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select compos();
---END---
---START---

drop function compos();
---END---
---START---
drop type compostype;
---END---
---START---

--
-- Tests for 8.4's new RAISE features
--

create or replace function raise_test() returns void as $$
begin
  raise notice '% % %', 1, 2, 3
     using errcode = '55001', detail = 'some detail info', hint = 'some hint';
---END---
---START---
  raise '% % %', 1, 2, 3
     using errcode = 'division_by_zero', detail = 'some detail info';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

-- Since we can't actually see the thrown SQLSTATE in default psql output,
-- test it like this; this also tests re-RAISE

create or replace function raise_test() returns void as $$
begin
  raise 'check me'
     using errcode = 'division_by_zero', detail = 'some detail info';
---END---
---START---
  exception
    when others then
      raise notice 'SQLSTATE: % SQLERRM: %', sqlstate, sqlerrm;
---END---
---START---
      raise;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise 'check me'
     using errcode = '1234F', detail = 'some detail info';
---END---
---START---
  exception
    when others then
      raise notice 'SQLSTATE: % SQLERRM: %', sqlstate, sqlerrm;
---END---
---START---
      raise;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

-- SQLSTATE specification in WHEN
create or replace function raise_test() returns void as $$
begin
  raise 'check me'
     using errcode = '1234F', detail = 'some detail info';
---END---
---START---
  exception
    when sqlstate '1234F' then
      raise notice 'SQLSTATE: % SQLERRM: %', sqlstate, sqlerrm;
---END---
---START---
      raise;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise division_by_zero using detail = 'some detail info';
---END---
---START---
  exception
    when others then
      raise notice 'SQLSTATE: % SQLERRM: %', sqlstate, sqlerrm;
---END---
---START---
      raise;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise division_by_zero;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise sqlstate '1234F';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise division_by_zero using message = 'custom' || ' message';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise using message = 'custom' || ' message', errcode = '22012';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

-- conflict on message
create or replace function raise_test() returns void as $$
begin
  raise notice 'some message' using message = 'custom' || ' message', errcode = '22012';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

-- conflict on errcode
create or replace function raise_test() returns void as $$
begin
  raise division_by_zero using message = 'custom' || ' message', errcode = '22012';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

-- nothing to re-RAISE
create or replace function raise_test() returns void as $$
begin
  raise;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

-- test access to exception data
create function zero_divide() returns int as $$
declare v int := 0;
---END---
---START---
begin
  return 10 / v;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create or replace function raise_test() returns void as $$
begin
  raise exception 'custom exception'
     using detail = 'some detail of custom exception',
           hint = 'some hint related to custom exception';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create function stacked_diagnostics_test() returns void as $$
declare _sqlstate text;
---END---
---START---
        _message text;
---END---
---START---
        _context text;
---END---
---START---
begin
  perform zero_divide();
---END---
---START---
exception when others then
  get stacked diagnostics
        _sqlstate = returned_sqlstate,
        _message = message_text,
        _context = pg_exception_context;
---END---
---START---
  raise notice 'sqlstate: %, message: %, context: [%]',
    _sqlstate, _message, replace(_context, E'\n', ' <- ');
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select stacked_diagnostics_test();
---END---
---START---

create or replace function stacked_diagnostics_test() returns void as $$
declare _detail text;
---END---
---START---
        _hint text;
---END---
---START---
        _message text;
---END---
---START---
begin
  perform raise_test();
---END---
---START---
exception when others then
  get stacked diagnostics
        _message = message_text,
        _detail = pg_exception_detail,
        _hint = pg_exception_hint;
---END---
---START---
  raise notice 'message: %, detail: %, hint: %', _message, _detail, _hint;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select stacked_diagnostics_test();
---END---
---START---

-- fail, cannot use stacked diagnostics statement outside handler
create or replace function stacked_diagnostics_test() returns void as $$
declare _detail text;
---END---
---START---
        _hint text;
---END---
---START---
        _message text;
---END---
---START---
begin
  get stacked diagnostics
        _message = message_text,
        _detail = pg_exception_detail,
        _hint = pg_exception_hint;
---END---
---START---
  raise notice 'message: %, detail: %, hint: %', _message, _detail, _hint;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select stacked_diagnostics_test();
---END---
---START---

drop function zero_divide();
---END---
---START---
drop function stacked_diagnostics_test();
---END---
---START---

-- check cases where implicit SQLSTATE variable could be confused with
-- SQLSTATE as a keyword, cf bug #5524
create or replace function raise_test() returns void as $$
begin
  perform 1/0;
---END---
---START---
exception
  when sqlstate '22012' then
    raise notice using message = sqlstate;
---END---
---START---
    raise sqlstate '22012' using message = 'substitute message';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select raise_test();
---END---
---START---

drop function raise_test();
---END---
---START---

-- test passing column_name, constraint_name, datatype_name, table_name
-- and schema_name error fields

create or replace function stacked_diagnostics_test() returns void as $$
declare _column_name text;
---END---
---START---
        _constraint_name text;
---END---
---START---
        _datatype_name text;
---END---
---START---
        _table_name text;
---END---
---START---
        _schema_name text;
---END---
---START---
begin
  raise exception using
    column = '>>some column name<<',
    constraint = '>>some constraint name<<',
    datatype = '>>some datatype name<<',
    table = '>>some table name<<',
    schema = '>>some schema name<<';
---END---
---START---
exception when others then
  get stacked diagnostics
        _column_name = column_name,
        _constraint_name = constraint_name,
        _datatype_name = pg_datatype_name,
        _table_name = table_name,
        _schema_name = schema_name;
---END---
---START---
  raise notice 'column %, constraint %, type %, table %, schema %',
    _column_name, _constraint_name, _datatype_name, _table_name, _schema_name;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select stacked_diagnostics_test();
---END---
---START---

drop function stacked_diagnostics_test();
---END---
---START---

-- test variadic functions

create or replace function vari(variadic int[])
returns void as $$
begin
  for i in array_lower($1,1)..array_upper($1,1) loop
    raise notice '%', $1[i];
---END---
---START---
  end loop; end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select vari(1,2,3,4,5);
---END---
---START---
select vari(3,4,5);
---END---
---START---
select vari(variadic array[5,6,7]);
---END---
---START---

drop function vari(int[]);
---END---
---START---

-- coercion test
create or replace function pleast(variadic numeric[])
returns numeric as $$
declare aux numeric = $1[array_lower($1,1)];
---END---
---START---
begin
  for i in array_lower($1,1)+1..array_upper($1,1) loop
    if $1[i] < aux then aux := $1[i]; end if;
---END---
---START---
  end loop;
---END---
---START---
  return aux;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql immutable strict;
---END---
---START---

select pleast(10,1,2,3,-16);
---END---
---START---
select pleast(10.2,2.2,-1.1);
---END---
---START---
select pleast(10.2,10, -20);
---END---
---START---
select pleast(10,20, -1.0);
---END---
---START---

-- in case of conflict, non-variadic version is preferred
create or replace function pleast(numeric)
returns numeric as $$
begin
  raise notice 'non-variadic function called';
---END---
---START---
  return $1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql immutable strict;
---END---
---START---

select pleast(10);
---END---
---START---

drop function pleast(numeric[]);
---END---
---START---
drop function pleast(numeric);
---END---
---START---

-- test table functions

create function tftest(int) returns table(a int, b int) as $$
begin
  return query select $1, $1+i from generate_series(1,5) g(i);
---END---
---START---
end;
---END---
---START---
$$ language plpgsql immutable strict;
---END---
---START---

select * from tftest(10);
---END---
---START---

create or replace function tftest(a1 int) returns table(a int, b int) as $$
begin
  a := a1; b := a1 + 1;
---END---
---START---
  return next;
---END---
---START---
  a := a1 * 10; b := a1 * 10 + 1;
---END---
---START---
  return next;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql immutable strict;
---END---
---START---

select * from tftest(10);
---END---
---START---

drop function tftest(int);
---END---
---START---

create function rttest()
returns setof int as $$
declare rc int;
---END---
---START---
begin
  return query values(10),(20);
---END---
---START---
  get diagnostics rc = row_count;
---END---
---START---
  raise notice '% %', found, rc;
---END---
---START---
  return query select * from (values(10),(20)) f(a) where false;
---END---
---START---
  get diagnostics rc = row_count;
---END---
---START---
  raise notice '% %', found, rc;
---END---
---START---
  return query execute 'values(10),(20)';
---END---
---START---
  get diagnostics rc = row_count;
---END---
---START---
  raise notice '% %', found, rc;
---END---
---START---
  return query execute 'select * from (values(10),(20)) f(a) where false';
---END---
---START---
  get diagnostics rc = row_count;
---END---
---START---
  raise notice '% %', found, rc;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from rttest();
---END---
---START---

-- check some error cases, too

create or replace function rttest()
returns setof int as $$
begin
  return query select 10 into no_such_table;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from rttest();
---END---
---START---

create or replace function rttest()
returns setof int as $$
begin
  return query execute 'select 10 into no_such_table';
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from rttest();
---END---
---START---

select * from no_such_table;
---END---
---START---

drop function rttest();
---END---
---START---

-- Test for proper cleanup at subtransaction exit.  This example
-- exposed a bug in PG 8.2.

CREATE FUNCTION leaker_1(fail BOOL) RETURNS INTEGER AS $$
DECLARE
  v_var INTEGER;
---END---
---START---
BEGIN
  BEGIN
    v_var := (leaker_2(fail)).error_code;
---END---
---START---
  EXCEPTION
    WHEN others THEN RETURN 0;
---END---
---START---
  END;
---END---
---START---
  RETURN 1;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

CREATE FUNCTION leaker_2(fail BOOL, OUT error_code INTEGER, OUT new_id INTEGER)
  RETURNS RECORD AS $$
BEGIN
  IF fail THEN
    RAISE EXCEPTION 'fail ...';
---END---
---START---
  END IF;
---END---
---START---
  error_code := 1;
---END---
---START---
  new_id := 1;
---END---
---START---
  RETURN;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

SELECT * FROM leaker_1(false);
---END---
---START---
SELECT * FROM leaker_1(true);
---END---
---START---

DROP FUNCTION leaker_1(bool);
---END---
---START---
DROP FUNCTION leaker_2(bool);
---END---
---START---

-- Test for appropriate cleanup of non-simple expression evaluations
-- (bug in all versions prior to August 2010)

CREATE FUNCTION nonsimple_expr_test() RETURNS text[] AS $$
DECLARE
  arr text[];
---END---
---START---
  lr text;
---END---
---START---
  i integer;
---END---
---START---
BEGIN
  arr := array[array['foo','bar'], array['baz', 'quux']];
---END---
---START---
  lr := 'fool';
---END---
---START---
  i := 1;
---END---
---START---
  -- use sub-SELECTs to make expressions non-simple
  arr[(SELECT i)][(SELECT i+1)] := (SELECT lr);
---END---
---START---
  RETURN arr;
---END---
---START---
END;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

SELECT nonsimple_expr_test();
---END---
---START---

DROP FUNCTION nonsimple_expr_test();
---END---
---START---

CREATE FUNCTION nonsimple_expr_test() RETURNS integer AS $$
declare
   i integer NOT NULL := 0;
---END---
---START---
begin
  begin
    i := (SELECT NULL::integer);  -- should throw error
  exception
    WHEN OTHERS THEN
      i := (SELECT 1::integer);
---END---
---START---
  end;
---END---
---START---
  return i;
---END---
---START---
end;
---END---
---START---
$$ LANGUAGE plpgsql;
---END---
---START---

SELECT nonsimple_expr_test();
---END---
---START---

DROP FUNCTION nonsimple_expr_test();
---END---
---START---

--
-- Test cases involving recursion and error recovery in simple expressions
-- (bugs in all versions before October 2010).  The problems are most
-- easily exposed by mutual recursion between plpgsql and sql functions.
--

create function recurse(float8) returns float8 as
$$
begin
  if ($1 > 0) then
    return sql_recurse($1 - 1);
---END---
---START---
  else
    return $1;
---END---
---START---
  end if;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

-- "limit" is to prevent this from being inlined
create function sql_recurse(float8) returns float8 as
$$ select recurse($1) limit 1; $$ language sql;
---END---
---START---

select recurse(10);
---END---
---START---

create function error1(text) returns text language sql as
$$ SELECT relname::text FROM pg_class c WHERE c.oid = $1::regclass $$;
---END---
---START---

create function error2(p_name_table text) returns text language plpgsql as $$
begin
  return error1(p_name_table);
---END---
---START---
end$$;
---END---
---START---

BEGIN;
---END---
---START---
create table public.stuffs (stuff text);
---END---
---START---
SAVEPOINT a;
---END---
---START---
select error2('nonexistent.stuffs');
---END---
---START---
ROLLBACK TO a;
---END---
---START---
select error2('public.stuffs');
---END---
---START---
rollback;
---END---
---START---

drop function error2(p_name_table text);
---END---
---START---
drop function error1(text);
---END---
---START---

-- Test for proper handling of cast-expression caching

create function sql_to_date(integer) returns date as $$
select $1::text::date
$$ language sql immutable strict;
---END---
---START---

create cast (integer as date) with function sql_to_date(integer) as assignment;
---END---
---START---

create function cast_invoker(integer) returns date as $$
begin
  return $1;
---END---
---START---
end$$ language plpgsql;
---END---
---START---

select cast_invoker(20150717);
---END---
---START---
select cast_invoker(20150718);  -- second call crashed in pre-release 9.5

begin;
---END---
---START---
select cast_invoker(20150717);
---END---
---START---
select cast_invoker(20150718);
---END---
---START---
savepoint s1;
---END---
---START---
select cast_invoker(20150718);
---END---
---START---
select cast_invoker(-1); -- fails
rollback to savepoint s1;
---END---
---START---
select cast_invoker(20150719);
---END---
---START---
select cast_invoker(20150720);
---END---
---START---
commit;
---END---
---START---

drop function cast_invoker(integer);
---END---
---START---
drop function sql_to_date(integer) cascade;
---END---
---START---

-- Test handling of cast cache inside DO blocks
-- (to check the original crash case, this must be a cast not previously
-- used in this session)

begin;
---END---
---START---
do $$ declare x text[]; begin x := '{1.23, 4.56}'::numeric[]; end $$;
---END---
---START---
do $$ declare x text[]; begin x := '{1.23, 4.56}'::numeric[]; end $$;
---END---
---START---
end;
---END---
---START---

-- Test for consistent reporting of error context

create function fail() returns int language plpgsql as $$
begin
  return 1/0;
---END---
---START---
end
$$;
---END---
---START---

select fail();
---END---
---START---
select fail();
---END---
---START---

drop function fail();
---END---
---START---

-- Test handling of string literals.

set standard_conforming_strings = off;
---END---
---START---

create or replace function strtest() returns text as $$
begin
  raise notice 'foo\\bar\041baz';
---END---
---START---
  return 'foo\\bar\041baz';
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select strtest();
---END---
---START---

create or replace function strtest() returns text as $$
begin
  raise notice E'foo\\bar\041baz';
---END---
---START---
  return E'foo\\bar\041baz';
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select strtest();
---END---
---START---

set standard_conforming_strings = on;
---END---
---START---

create or replace function strtest() returns text as $$
begin
  raise notice 'foo\\bar\041baz\';
---END---
---START---
  return 'foo\\bar\041baz\';
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select strtest();
---END---
---START---

create or replace function strtest() returns text as $$
begin
  raise notice E'foo\\bar\041baz';
---END---
---START---
  return E'foo\\bar\041baz';
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select strtest();
---END---
---START---

drop function strtest();
---END---
---START---

-- Test anonymous code blocks.

DO $$
DECLARE r record;
---END---
---START---
BEGIN
    FOR r IN SELECT rtrim(roomno) AS roomno, comment FROM Room ORDER BY roomno
    LOOP
        RAISE NOTICE '%, %', r.roomno, r.comment;
---END---
---START---
    END LOOP;
---END---
---START---
END$$;
---END---
---START---

-- these are to check syntax error reporting
DO LANGUAGE plpgsql $$begin return 1; end$$;
---END---
---START---

DO $$
DECLARE r record;
---END---
---START---
BEGIN
    FOR r IN SELECT rtrim(roomno) AS roomno, foo FROM Room ORDER BY roomno
    LOOP
        RAISE NOTICE '%, %', r.roomno, r.comment;
---END---
---START---
    END LOOP;
---END---
---START---
END$$;
---END---
---START---

-- Check handling of errors thrown from/into anonymous code blocks.
do $outer$
begin
  for i in 1..10 loop
   begin
    execute $ex$
      do $$
      declare x int = 0;
---END---
---START---
      begin
        x := 1 / x;
---END---
---START---
      end;
---END---
---START---
      $$;
---END---
---START---
    $ex$;
---END---
---START---
  exception when division_by_zero then
    raise notice 'caught division by zero';
---END---
---START---
  end;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$outer$;
---END---
---START---

-- Check variable scoping -- a var is not available in its own or prior
-- default expressions, but it is available in later ones.

do $$
declare x int := x + 1;  -- error
begin
  raise notice 'x = %', x;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare y int := x + 1;  -- error
        x int := 42;
---END---
---START---
begin
  raise notice 'x = %, y = %', x, y;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare x int := 42;
---END---
---START---
        y int := x + 1;
---END---
---START---
begin
  raise notice 'x = %, y = %', x, y;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare x int := 42;
---END---
---START---
begin
  declare y int := x + 1;
---END---
---START---
          x int := x + 2;
---END---
---START---
          z int := x * 10;
---END---
---START---
  begin
    raise notice 'x = %, y = %, z = %', x, y, z;
---END---
---START---
  end;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

-- Check handling of conflicts between plpgsql vars and table columns.

set plpgsql.variable_conflict = error;
---END---
---START---

create function conflict_test() returns setof int8_tbl as $$
declare r record;
---END---
---START---
  q1 bigint := 42;
---END---
---START---
begin
  for r in select q1,q2 from int8_tbl loop
    return next r;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from conflict_test();
---END---
---START---

create or replace function conflict_test() returns setof int8_tbl as $$
#variable_conflict use_variable
declare r record;
---END---
---START---
  q1 bigint := 42;
---END---
---START---
begin
  for r in select q1,q2 from int8_tbl loop
    return next r;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from conflict_test();
---END---
---START---

create or replace function conflict_test() returns setof int8_tbl as $$
#variable_conflict use_column
declare r record;
---END---
---START---
  q1 bigint := 42;
---END---
---START---
begin
  for r in select q1,q2 from int8_tbl loop
    return next r;
---END---
---START---
  end loop;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select * from conflict_test();
---END---
---START---

drop function conflict_test();
---END---
---START---

-- Check that an unreserved keyword can be used as a variable name

create function unreserved_test() returns int as $$
declare
  forward int := 21;
---END---
---START---
begin
  forward := forward * 2;
---END---
---START---
  return forward;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select unreserved_test();
---END---
---START---

create or replace function unreserved_test() returns int as $$
declare
  return int := 42;
---END---
---START---
begin
  return := return + 1;
---END---
---START---
  return return;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select unreserved_test();
---END---
---START---

create or replace function unreserved_test() returns int as $$
declare
  comment int := 21;
---END---
---START---
begin
  comment := comment * 2;
---END---
---START---
  comment on function unreserved_test() is 'this is a test';
---END---
---START---
  return comment;
---END---
---START---
end
$$ language plpgsql;
---END---
---START---

select unreserved_test();
---END---
---START---

select obj_description('unreserved_test()'::regprocedure, 'pg_proc');
---END---
---START---

drop function unreserved_test();
---END---
---START---

--
-- Test FOREACH over arrays
--

create function foreach_test(anyarray)
returns void as $$
declare x int;
---END---
---START---
begin
  foreach x in array $1
  loop
    raise notice '%', x;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select foreach_test(ARRAY[1,2,3,4]);
---END---
---START---
select foreach_test(ARRAY[[1,2],[3,4]]);
---END---
---START---

create or replace function foreach_test(anyarray)
returns void as $$
declare x int;
---END---
---START---
begin
  foreach x slice 1 in array $1
  loop
    raise notice '%', x;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

-- should fail
select foreach_test(ARRAY[1,2,3,4]);
---END---
---START---
select foreach_test(ARRAY[[1,2],[3,4]]);
---END---
---START---

create or replace function foreach_test(anyarray)
returns void as $$
declare x int[];
---END---
---START---
begin
  foreach x slice 1 in array $1
  loop
    raise notice '%', x;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select foreach_test(ARRAY[1,2,3,4]);
---END---
---START---
select foreach_test(ARRAY[[1,2],[3,4]]);
---END---
---START---

-- higher level of slicing
create or replace function foreach_test(anyarray)
returns void as $$
declare x int[];
---END---
---START---
begin
  foreach x slice 2 in array $1
  loop
    raise notice '%', x;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

-- should fail
select foreach_test(ARRAY[1,2,3,4]);
---END---
---START---
-- ok
select foreach_test(ARRAY[[1,2],[3,4]]);
---END---
---START---
select foreach_test(ARRAY[[[1,2]],[[3,4]]]);
---END---
---START---

create type xy_tuple AS (x int, y int);
---END---
---START---

-- iteration over array of records
create or replace function foreach_test(anyarray)
returns void as $$
declare r record;
---END---
---START---
begin
  foreach r in array $1
  loop
    raise notice '%', r;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select foreach_test(ARRAY[(10,20),(40,69),(35,78)]::xy_tuple[]);
---END---
---START---
select foreach_test(ARRAY[[(10,20),(40,69)],[(35,78),(88,76)]]::xy_tuple[]);
---END---
---START---

create or replace function foreach_test(anyarray)
returns void as $$
declare x int; y int;
---END---
---START---
begin
  foreach x, y in array $1
  loop
    raise notice 'x = %, y = %', x, y;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select foreach_test(ARRAY[(10,20),(40,69),(35,78)]::xy_tuple[]);
---END---
---START---
select foreach_test(ARRAY[[(10,20),(40,69)],[(35,78),(88,76)]]::xy_tuple[]);
---END---
---START---

-- slicing over array of composite types
create or replace function foreach_test(anyarray)
returns void as $$
declare x xy_tuple[];
---END---
---START---
begin
  foreach x slice 1 in array $1
  loop
    raise notice '%', x;
---END---
---START---
  end loop;
---END---
---START---
  end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select foreach_test(ARRAY[(10,20),(40,69),(35,78)]::xy_tuple[]);
---END---
---START---
select foreach_test(ARRAY[[(10,20),(40,69)],[(35,78),(88,76)]]::xy_tuple[]);
---END---
---START---

drop function foreach_test(anyarray);
---END---
---START---
drop type xy_tuple;
---END---
---START---

--
-- Assorted tests for array subscript assignment
--

create temp table rtype (id int, ar text[]);
---END---
---START---

create function arrayassign1() returns text[] language plpgsql as $$
declare
 r record;
---END---
---START---
begin
  r := row(12, '{foo,bar,baz}')::rtype;
---END---
---START---
  r.ar[2] := 'replace';
---END---
---START---
  return r.ar;
---END---
---START---
end$$;
---END---
---START---

select arrayassign1();
---END---
---START---
select arrayassign1(); -- try again to exercise internal caching

create domain orderedarray as int[2]
  constraint sorted check (value[1] < value[2]);
---END---
---START---

select '{1,2}'::orderedarray;
---END---
---START---
select '{2,1}'::orderedarray;  -- fail

create function testoa(x1 int, x2 int, x3 int) returns orderedarray
language plpgsql as $$
declare res orderedarray;
---END---
---START---
begin
  res := array[x1, x2];
---END---
---START---
  res[2] := x3;
---END---
---START---
  return res;
---END---
---START---
end$$;
---END---
---START---

select testoa(1,2,3);
---END---
---START---
select testoa(1,2,3); -- try again to exercise internal caching
select testoa(2,1,3); -- fail at initial assign
select testoa(1,2,1); -- fail at update

drop function arrayassign1();
---END---
---START---
drop function testoa(x1 int, x2 int, x3 int);
---END---
---START---


--
-- Test handling of expanded arrays
--

create function returns_rw_array(int) returns int[]
language plpgsql as $$
  declare r int[];
---END---
---START---
  begin r := array[$1, $1]; return r; end;
---END---
---START---
$$ stable;
---END---
---START---

create function consumes_rw_array(int[]) returns int
language plpgsql as $$
  begin return $1[1]; end;
---END---
---START---
$$ stable;
---END---
---START---

select consumes_rw_array(returns_rw_array(42));
---END---
---START---

-- bug #14174
explain (verbose, costs off)
select i, a from
  (select returns_rw_array(1) as a offset 0) ss,
  lateral consumes_rw_array(a) i;
---END---
---START---

select i, a from
  (select returns_rw_array(1) as a offset 0) ss,
  lateral consumes_rw_array(a) i;
---END---
---START---

explain (verbose, costs off)
select consumes_rw_array(a), a from returns_rw_array(1) a;
---END---
---START---

select consumes_rw_array(a), a from returns_rw_array(1) a;
---END---
---START---

explain (verbose, costs off)
select consumes_rw_array(a), a from
  (values (returns_rw_array(1)), (returns_rw_array(2))) v(a);
---END---
---START---

select consumes_rw_array(a), a from
  (values (returns_rw_array(1)), (returns_rw_array(2))) v(a);
---END---
---START---

do $$
declare a int[] := array[1,2];
---END---
---START---
begin
  a := a || 3;
---END---
---START---
  raise notice 'a = %', a;
---END---
---START---
end$$;
---END---
---START---


--
-- Test access to call stack
--

create function inner_func(int)
returns int as $$
declare _context text;
---END---
---START---
begin
  get diagnostics _context = pg_context;
---END---
---START---
  raise notice '***%***', _context;
---END---
---START---
  -- lets do it again, just for fun..
  get diagnostics _context = pg_context;
---END---
---START---
  raise notice '***%***', _context;
---END---
---START---
  raise notice 'lets make sure we didnt break anything';
---END---
---START---
  return 2 * $1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create or replace function outer_func(int)
returns int as $$
declare
  myresult int;
---END---
---START---
begin
  raise notice 'calling down into inner_func()';
---END---
---START---
  myresult := inner_func($1);
---END---
---START---
  raise notice 'inner_func() done';
---END---
---START---
  return myresult;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create or replace function outer_outer_func(int)
returns int as $$
declare
  myresult int;
---END---
---START---
begin
  raise notice 'calling down into outer_func()';
---END---
---START---
  myresult := outer_func($1);
---END---
---START---
  raise notice 'outer_func() done';
---END---
---START---
  return myresult;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select outer_outer_func(10);
---END---
---START---
-- repeated call should work
select outer_outer_func(20);
---END---
---START---

drop function outer_outer_func(int);
---END---
---START---
drop function outer_func(int);
---END---
---START---
drop function inner_func(int);
---END---
---START---

-- access to call stack from exception
create function inner_func(int)
returns int as $$
declare
  _context text;
---END---
---START---
  sx int := 5;
---END---
---START---
begin
  begin
    perform sx / 0;
---END---
---START---
  exception
    when division_by_zero then
      get diagnostics _context = pg_context;
---END---
---START---
      raise notice '***%***', _context;
---END---
---START---
  end;
---END---
---START---

  -- lets do it again, just for fun..
  get diagnostics _context = pg_context;
---END---
---START---
  raise notice '***%***', _context;
---END---
---START---
  raise notice 'lets make sure we didnt break anything';
---END---
---START---
  return 2 * $1;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create or replace function outer_func(int)
returns int as $$
declare
  myresult int;
---END---
---START---
begin
  raise notice 'calling down into inner_func()';
---END---
---START---
  myresult := inner_func($1);
---END---
---START---
  raise notice 'inner_func() done';
---END---
---START---
  return myresult;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

create or replace function outer_outer_func(int)
returns int as $$
declare
  myresult int;
---END---
---START---
begin
  raise notice 'calling down into outer_func()';
---END---
---START---
  myresult := outer_func($1);
---END---
---START---
  raise notice 'outer_func() done';
---END---
---START---
  return myresult;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select outer_outer_func(10);
---END---
---START---
-- repeated call should work
select outer_outer_func(20);
---END---
---START---

drop function outer_outer_func(int);
---END---
---START---
drop function outer_func(int);
---END---
---START---
drop function inner_func(int);
---END---
---START---

-- Test pg_routine_oid
create function current_function(text)
returns regprocedure as $$
declare
  fn_oid regprocedure;
---END---
---START---
begin
  get diagnostics fn_oid = pg_routine_oid;
---END---
---START---
  return fn_oid;
---END---
---START---
end;
---END---
---START---
$$ language plpgsql;
---END---
---START---

select current_function('foo');
---END---
---START---

drop function current_function(text);
---END---
---START---

-- shouldn't fail in DO, even though there's no useful data
do $$
declare
  fn_oid oid;
---END---
---START---
begin
  get diagnostics fn_oid = pg_routine_oid;
---END---
---START---
  raise notice 'pg_routine_oid = %', fn_oid;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

--
-- Test ASSERT
--

do $$
begin
  assert 1=1;  -- should succeed
end;
---END---
---START---
$$;
---END---
---START---

do $$
begin
  assert 1=0;  -- should fail
end;
---END---
---START---
$$;
---END---
---START---

do $$
begin
  assert NULL;  -- should fail
end;
---END---
---START---
$$;
---END---
---START---

-- check controlling GUC
set plpgsql.check_asserts = off;
---END---
---START---
do $$
begin
  assert 1=0;  -- won't be tested
end;
---END---
---START---
$$;
---END---
---START---
reset plpgsql.check_asserts;
---END---
---START---

-- test custom message
do $$
declare var text := 'some value';
---END---
---START---
begin
  assert 1=0, format('assertion failed, var = "%s"', var);
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

-- ensure assertions are not trapped by 'others'
do $$
begin
  assert 1=0, 'unhandled assertion';
---END---
---START---
exception when others then
  null; -- do nothing
end;
---END---
---START---
$$;
---END---
---START---

-- Test use of plpgsql in a domain check constraint (cf. bug #14414)

create function plpgsql_domain_check(val int) returns boolean as $$
begin return val > 0; end
$$ language plpgsql immutable;
---END---
---START---

create domain plpgsql_domain as integer check(plpgsql_domain_check(value));
---END---
---START---

do $$
declare v_test plpgsql_domain;
---END---
---START---
begin
  v_test := 1;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare v_test plpgsql_domain := 1;
---END---
---START---
begin
  v_test := 0;  -- fail
end;
---END---
---START---
$$;
---END---
---START---

-- Test handling of expanded array passed to a domain constraint (bug #14472)

create function plpgsql_arr_domain_check(val int[]) returns boolean as $$
begin return val[1] > 0; end
$$ language plpgsql immutable;
---END---
---START---

create domain plpgsql_arr_domain as int[] check(plpgsql_arr_domain_check(value));
---END---
---START---

do $$
declare v_test plpgsql_arr_domain;
---END---
---START---
begin
  v_test := array[1];
---END---
---START---
  v_test := v_test || 2;
---END---
---START---
end;
---END---
---START---
$$;
---END---
---START---

do $$
declare v_test plpgsql_arr_domain := array[1];
---END---
---START---
begin
  v_test := 0 || v_test;  -- fail
end;
---END---
---START---
$$;
---END---
---START---

--
-- test usage of transition tables in AFTER triggers
--

CREATE TABLE transition_table_base (id int PRIMARY KEY, val text);
---END---
---START---

CREATE FUNCTION transition_table_base_ins_func()
  RETURNS trigger
  LANGUAGE plpgsql
AS $$
DECLARE
  t text;
---END---
---START---
  l text;
---END---
---START---
BEGIN
  t = '';
---END---
---START---
  FOR l IN EXECUTE
           $q$
             EXPLAIN (TIMING off, COSTS off, VERBOSE on)
             SELECT * FROM newtable
           $q$ LOOP
    t = t || l || E'\n';
---END---
---START---
  END LOOP;
---END---
---START---

  RAISE INFO '%', t;
---END---
---START---
  RETURN new;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

CREATE TRIGGER transition_table_base_ins_trig
  AFTER INSERT ON transition_table_base
  REFERENCING OLD TABLE AS oldtable NEW TABLE AS newtable
  FOR EACH STATEMENT
  EXECUTE PROCEDURE transition_table_base_ins_func();
---END---
---START---

CREATE TRIGGER transition_table_base_ins_trig
  AFTER INSERT ON transition_table_base
  REFERENCING NEW TABLE AS newtable
  FOR EACH STATEMENT
  EXECUTE PROCEDURE transition_table_base_ins_func();
---END---
---START---

INSERT INTO transition_table_base VALUES (1, 'One'), (2, 'Two');
---END---
---START---
INSERT INTO transition_table_base VALUES (3, 'Three'), (4, 'Four');
---END---
---START---

CREATE OR REPLACE FUNCTION transition_table_base_upd_func()
  RETURNS trigger
  LANGUAGE plpgsql
AS $$
DECLARE
  t text;
---END---
---START---
  l text;
---END---
---START---
BEGIN
  t = '';
---END---
---START---
  FOR l IN EXECUTE
           $q$
             EXPLAIN (TIMING off, COSTS off, VERBOSE on)
             SELECT * FROM oldtable ot FULL JOIN newtable nt USING (id)
           $q$ LOOP
    t = t || l || E'\n';
---END---
---START---
  END LOOP;
---END---
---START---

  RAISE INFO '%', t;
---END---
---START---
  RETURN new;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

CREATE TRIGGER transition_table_base_upd_trig
  AFTER UPDATE ON transition_table_base
  REFERENCING OLD TABLE AS oldtable NEW TABLE AS newtable
  FOR EACH STATEMENT
  EXECUTE PROCEDURE transition_table_base_upd_func();
---END---
---START---

UPDATE transition_table_base
  SET val = '*' || val || '*'
  WHERE id BETWEEN 2 AND 3;
---END---
---START---

CREATE TABLE transition_table_level1
(
      level1_no serial NOT NULL ,
      level1_node_name varchar(255),
       PRIMARY KEY (level1_no)
) WITHOUT OIDS;
---END---
---START---

CREATE TABLE transition_table_level2
(
      level2_no serial NOT NULL ,
      parent_no int NOT NULL,
      level1_node_name varchar(255),
       PRIMARY KEY (level2_no)
) WITHOUT OIDS;
---END---
---START---

CREATE TABLE transition_table_status
(
      level int NOT NULL,
      node_no int NOT NULL,
      status int,
       PRIMARY KEY (level, node_no)
) WITHOUT OIDS;
---END---
---START---

CREATE FUNCTION transition_table_level1_ri_parent_del_func()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
  DECLARE n bigint;
---END---
---START---
  BEGIN
    PERFORM FROM p JOIN transition_table_level2 c ON c.parent_no = p.level1_no;
---END---
---START---
    IF FOUND THEN
      RAISE EXCEPTION 'RI error';
---END---
---START---
    END IF;
---END---
---START---
    RETURN NULL;
---END---
---START---
  END;
---END---
---START---
$$;
---END---
---START---

CREATE TRIGGER transition_table_level1_ri_parent_del_trigger
  AFTER DELETE ON transition_table_level1
  REFERENCING OLD TABLE AS p
  FOR EACH STATEMENT EXECUTE PROCEDURE
    transition_table_level1_ri_parent_del_func();
---END---
---START---

CREATE FUNCTION transition_table_level1_ri_parent_upd_func()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
  DECLARE
    x int;
---END---
---START---
  BEGIN
    WITH p AS (SELECT level1_no, sum(delta) cnt
                 FROM (SELECT level1_no, 1 AS delta FROM i
                       UNION ALL
                       SELECT level1_no, -1 AS delta FROM d) w
                 GROUP BY level1_no
                 HAVING sum(delta) < 0)
    SELECT level1_no
      FROM p JOIN transition_table_level2 c ON c.parent_no = p.level1_no
      INTO x;
---END---
---START---
    IF FOUND THEN
      RAISE EXCEPTION 'RI error';
---END---
---START---
    END IF;
---END---
---START---
    RETURN NULL;
---END---
---START---
  END;
---END---
---START---
$$;
---END---
---START---

CREATE TRIGGER transition_table_level1_ri_parent_upd_trigger
  AFTER UPDATE ON transition_table_level1
  REFERENCING OLD TABLE AS d NEW TABLE AS i
  FOR EACH STATEMENT EXECUTE PROCEDURE
    transition_table_level1_ri_parent_upd_func();
---END---
---START---

CREATE FUNCTION transition_table_level2_ri_child_insupd_func()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
  BEGIN
    PERFORM FROM i
      LEFT JOIN transition_table_level1 p
        ON p.level1_no IS NOT NULL AND p.level1_no = i.parent_no
      WHERE p.level1_no IS NULL;
---END---
---START---
    IF FOUND THEN
      RAISE EXCEPTION 'RI error';
---END---
---START---
    END IF;
---END---
---START---
    RETURN NULL;
---END---
---START---
  END;
---END---
---START---
$$;
---END---
---START---

CREATE TRIGGER transition_table_level2_ri_child_ins_trigger
  AFTER INSERT ON transition_table_level2
  REFERENCING NEW TABLE AS i
  FOR EACH STATEMENT EXECUTE PROCEDURE
    transition_table_level2_ri_child_insupd_func();
---END---
---START---

CREATE TRIGGER transition_table_level2_ri_child_upd_trigger
  AFTER UPDATE ON transition_table_level2
  REFERENCING NEW TABLE AS i
  FOR EACH STATEMENT EXECUTE PROCEDURE
    transition_table_level2_ri_child_insupd_func();
---END---
---START---

-- create initial test data
INSERT INTO transition_table_level1 (level1_no)
  SELECT generate_series(1,200);
---END---
---START---
ANALYZE transition_table_level1;
---END---
---START---

INSERT INTO transition_table_level2 (level2_no, parent_no)
  SELECT level2_no, level2_no / 50 + 1 AS parent_no
    FROM generate_series(1,9999) level2_no;
---END---
---START---
ANALYZE transition_table_level2;
---END---
---START---

INSERT INTO transition_table_status (level, node_no, status)
  SELECT 1, level1_no, 0 FROM transition_table_level1;
---END---
---START---

INSERT INTO transition_table_status (level, node_no, status)
  SELECT 2, level2_no, 0 FROM transition_table_level2;
---END---
---START---
ANALYZE transition_table_status;
---END---
---START---

INSERT INTO transition_table_level1(level1_no)
  SELECT generate_series(201,1000);
---END---
---START---
ANALYZE transition_table_level1;
---END---
---START---

-- behave reasonably if someone tries to modify a transition table
CREATE FUNCTION transition_table_level2_bad_usage_func()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
  BEGIN
    INSERT INTO dx VALUES (1000000, 1000000, 'x');
---END---
---START---
    RETURN NULL;
---END---
---START---
  END;
---END---
---START---
$$;
---END---
---START---

CREATE TRIGGER transition_table_level2_bad_usage_trigger
  AFTER DELETE ON transition_table_level2
  REFERENCING OLD TABLE AS dx
  FOR EACH STATEMENT EXECUTE PROCEDURE
    transition_table_level2_bad_usage_func();
---END---
---START---

DELETE FROM transition_table_level2
  WHERE level2_no BETWEEN 301 AND 305;
---END---
---START---

DROP TRIGGER transition_table_level2_bad_usage_trigger
  ON transition_table_level2;
---END---
---START---

-- attempt modifications which would break RI (should all fail)
DELETE FROM transition_table_level1
  WHERE level1_no = 25;
---END---
---START---

UPDATE transition_table_level1 SET level1_no = -1
  WHERE level1_no = 30;
---END---
---START---

INSERT INTO transition_table_level2 (level2_no, parent_no)
  VALUES (10000, 10000);
---END---
---START---

UPDATE transition_table_level2 SET parent_no = 2000
  WHERE level2_no = 40;
---END---
---START---


-- attempt modifications which would not break RI (should all succeed)
DELETE FROM transition_table_level1
  WHERE level1_no BETWEEN 201 AND 1000;
---END---
---START---

DELETE FROM transition_table_level1
  WHERE level1_no BETWEEN 100000000 AND 100000010;
---END---
---START---

SELECT count(*) FROM transition_table_level1;
---END---
---START---

DELETE FROM transition_table_level2
  WHERE level2_no BETWEEN 211 AND 220;
---END---
---START---

SELECT count(*) FROM transition_table_level2;
---END---
---START---

CREATE TABLE alter_table_under_transition_tables
(
  id int PRIMARY KEY,
  name text
);
---END---
---START---

CREATE FUNCTION alter_table_under_transition_tables_upd_func()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
BEGIN
  RAISE WARNING 'old table = %, new table = %',
                  (SELECT string_agg(id || '=' || name, ',') FROM d),
                  (SELECT string_agg(id || '=' || name, ',') FROM i);
---END---
---START---
  RAISE NOTICE 'one = %', (SELECT 1 FROM alter_table_under_transition_tables LIMIT 1);
---END---
---START---
  RETURN NULL;
---END---
---START---
END;
---END---
---START---
$$;
---END---
---START---

-- should fail, TRUNCATE is not compatible with transition tables
CREATE TRIGGER alter_table_under_transition_tables_upd_trigger
  AFTER TRUNCATE OR UPDATE ON alter_table_under_transition_tables
  REFERENCING OLD TABLE AS d NEW TABLE AS i
  FOR EACH STATEMENT EXECUTE PROCEDURE
    alter_table_under_transition_tables_upd_func();
---END---
---START---

-- should work
CREATE TRIGGER alter_table_under_transition_tables_upd_trigger
  AFTER UPDATE ON alter_table_under_transition_tables
  REFERENCING OLD TABLE AS d NEW TABLE AS i
  FOR EACH STATEMENT EXECUTE PROCEDURE
    alter_table_under_transition_tables_upd_func();
---END---
---START---

INSERT INTO alter_table_under_transition_tables
  VALUES (1, '1'), (2, '2'), (3, '3');
---END---
---START---
UPDATE alter_table_under_transition_tables
  SET name = name || name;
---END---
---START---

-- now change 'name' to an integer to see what happens...
ALTER TABLE alter_table_under_transition_tables
  ALTER COLUMN name TYPE int USING name::integer;
---END---
---START---
UPDATE alter_table_under_transition_tables
  SET name = (name::text || name::text)::integer;
---END---
---START---

-- now drop column 'name'
ALTER TABLE alter_table_under_transition_tables
  DROP column name;
---END---
---START---
UPDATE alter_table_under_transition_tables
  SET id = id;
---END---
---START---

--
-- Test multiple reference to a transition table
--

CREATE TABLE multi_test (i int);
---END---
---START---
INSERT INTO multi_test VALUES (1);
---END---
---START---

CREATE OR REPLACE FUNCTION multi_test_trig() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE NOTICE 'count = %', (SELECT COUNT(*) FROM new_test);
---END---
---START---
    RAISE NOTICE 'count union = %',
      (SELECT COUNT(*)
       FROM (SELECT * FROM new_test UNION ALL SELECT * FROM new_test) ss);
---END---
---START---
    RETURN NULL;
---END---
---START---
END$$;
---END---
---START---

CREATE TRIGGER my_trigger AFTER UPDATE ON multi_test
  REFERENCING NEW TABLE AS new_test OLD TABLE as old_test
  FOR EACH STATEMENT EXECUTE PROCEDURE multi_test_trig();
---END---
---START---

UPDATE multi_test SET i = i;
---END---
---START---

DROP TABLE multi_test;
---END---
---START---
DROP FUNCTION multi_test_trig();
---END---
---START---

--
-- Check type parsing and record fetching from partitioned tables
--

CREATE TABLE partitioned_table (a int, b text) PARTITION BY LIST (a);
---END---
---START---
CREATE TABLE pt_part1 PARTITION OF partitioned_table FOR VALUES IN (1);
---END---
---START---
CREATE TABLE pt_part2 PARTITION OF partitioned_table FOR VALUES IN (2);
---END---
---START---

INSERT INTO partitioned_table VALUES (1, 'Row 1');
---END---
---START---
INSERT INTO partitioned_table VALUES (2, 'Row 2');
---END---
---START---

CREATE OR REPLACE FUNCTION get_from_partitioned_table(partitioned_table.a%type)
RETURNS partitioned_table AS $$
DECLARE
    a_val partitioned_table.a%TYPE;
---END---
---START---
    result partitioned_table%ROWTYPE;
---END---
---START---
BEGIN
    a_val := $1;
---END---
---START---
    SELECT * INTO result FROM partitioned_table WHERE a = a_val;
---END---
---START---
    RETURN result;
---END---
---START---
END; $$ LANGUAGE plpgsql;
---END---
---START---

SELECT * FROM get_from_partitioned_table(1) AS t;
---END---
---START---

CREATE OR REPLACE FUNCTION list_partitioned_table()
RETURNS SETOF partitioned_table.a%TYPE AS $$
DECLARE
    row partitioned_table%ROWTYPE;
---END---
---START---
    a_val partitioned_table.a%TYPE;
---END---
---START---
BEGIN
    FOR row IN SELECT * FROM partitioned_table ORDER BY a LOOP
        a_val := row.a;
---END---
---START---
        RETURN NEXT a_val;
---END---
---START---
    END LOOP;
---END---
---START---
    RETURN;
---END---
---START---
END; $$ LANGUAGE plpgsql;
---END---
---START---

SELECT * FROM list_partitioned_table() AS t;
---END---
---START---

--
-- Check argument name is used instead of $n in error message
--
CREATE FUNCTION fx(x WSlot) RETURNS void AS $$
BEGIN
  GET DIAGNOSTICS x = ROW_COUNT;
---END---
---START---
  RETURN;
---END---
---START---
END; $$ LANGUAGE plpgsql;
---END---
