CREATE OR REPLACE PACKAGE pkg_admin_tools AS

  --records
  TYPE r_result_of_status IS RECORD(
     status_object VARCHAR2(128)
    ,type_object   VARCHAR2(256)
    ,name_object   VARCHAR2(512));

  --collections
  TYPE c_status_result IS TABLE OF r_result_of_status INDEX BY PLS_INTEGER;

  --procedure
  PROCEDURE grants_to_owner(p_from_owner  VARCHAR2
                           ,p_to_owner    VARCHAR2
                           ,p_type_object VARCHAR2
                           ,p_type_action VARCHAR2 DEFAULT 'all');

END pkg_admin_tools;
/
CREATE OR REPLACE PACKAGE BODY pkg_admin_tools AS

  --procedure
  PROCEDURE record_logs(p_text VARCHAR2) IS
    log_file utl_file.file_type;
  BEGIN
    log_file := utl_file.fopen('DIR_LOG', 'log_' || to_char(SYSDATE, 'mm_dd_yyyy') || '.txt', 'w');
    utl_file.put_line(log_file, p_text);
    utl_file.fclose(log_file);
  END;

  PROCEDURE grants_to_owner(p_from_owner  VARCHAR2
                           ,p_to_owner    VARCHAR2
                           ,p_type_object VARCHAR2
                           ,p_type_action VARCHAR2 DEFAULT 'all') IS
  
    CURSOR c_set_objects(p_owner VARCHAR2
                        ,p_type  VARCHAR2) IS
      SELECT *
        FROM all_objects
       WHERE owner = upper(p_owner)
         AND object_type = upper(p_type);
  
  BEGIN
  
    FOR i IN c_set_objects(p_from_owner, p_type_object)
    LOOP
    
      <<get_grants>>
      BEGIN
        EXECUTE IMMEDIATE 'grant ' || p_type_action || ' on ' || i.owner || '.' || i.object_name || ' to ' ||
                          p_to_owner;
      EXCEPTION
        WHEN OTHERS THEN
          record_logs('--Backtrace--');
          record_logs(dbms_utility.format_error_backtrace);
          record_logs('--Text error--');
          record_logs(dbms_utility.format_error_stack);
      END;
    END LOOP;
  
  END grants_to_owner;

END pkg_admin_tools;
/
