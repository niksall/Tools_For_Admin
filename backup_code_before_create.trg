create or replace noneditionable trigger backup_code_before_create
  before create on schema
declare

  type r_option_for_record is record(
    sys_owner all_source.owner%type
    ,sys_type all_source.type%type
    ,sys_name all_source.name%type 
    ,sys_date db_backup_objects.createdate%type);
  l_option_for_record r_option_for_record;
  
  l_check_version     number;

begin

  select sys_context('userenv', 'current_schema'),
         sys.dictionary_obj_type,
         sys.dictionary_obj_name,
         trunc(sysdate)
    into l_option_for_record
    from dual;

  begin 

    select decode(db_o.versions_obj, null, 1, 0)
      into l_check_version
      from db_backup_objects db_o
     where db_o.createdate = l_option_for_record.sys_date
       and db_o.owner_obj = l_option_for_record.sys_owner
       and db_o.type_obj = l_option_for_record.sys_type
       and db_o.name_obj = l_option_for_record.sys_name;
  
  exception 
    when no_data_found 
         then l_check_version := 1;
  end;

  if l_check_version = 1 then
    insert into db_backup_objects
      (versions_obj,
       owner_obj,
       createdate,
       name_obj,
       type_obj,
       description_obj)
      with get_obj
      (out_owner, out_date, out_name, out_type) as
       (select distinct owner, trunc(sysdate), name, type
          from all_source
         where owner = l_option_for_record.sys_owner
           and type = l_option_for_record.sys_type
           and name = l_option_for_record.sys_name)
      select dense_rank() over (partition by out_owner, out_date order by out_date ) as version,
             out_owner,
             out_date,
             out_name,
             out_type,
             dbms_metadata.get_ddl(out_type, out_name)
        from get_obj;
  else
    update db_backup_objects
       set description_obj = dbms_metadata.get_ddl(l_option_for_record.sys_type,
                                                   l_option_for_record.sys_name)
     where createdate = l_option_for_record.sys_date
       and owner_obj = l_option_for_record.sys_owner
       and type_obj = l_option_for_record.sys_type
       and name_obj = l_option_for_record.sys_name;
  end if;
end;
/
