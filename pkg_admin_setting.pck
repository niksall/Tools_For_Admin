CREATE OR REPLACE PACKAGE pkg_admin_setting AS

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

END pkg_admin_setting;
/
CREATE OR REPLACE PACKAGE BODY pkg_admin_setting AS

  --procedure
  PROCEDURE record_logs(p_text VARCHAR2) IS
    log_file utl_file.file_type;
  BEGIN
    log_file := utl_file.fopen('DIR_LOG', 'log_' || to_char(SYSDATE, 'mm_dd_yyyy') || '.txt', 'w');
    utl_file.put_line(log_file, p_text);
    utl_file.fclose(log_file);
  END;
  
  procedure format_error(p_text_error_stack varchar2) is
    l_text_error_stack varchar2(512) := p_text_error_stack;
    cursor c_line_error(p_owner varchar2, p_object_name varchar2, p_number_line number) is
          select * 
                 from all_source 
          where owner = p_owner
                and name = p_object_name
                and line = p_number_line;
    begin
       
      /* WITH error_set(lvl, text) AS
         (SELECT 1 AS lvl
                ,l_text_error_stack AS text
            FROM dual
          UNION ALL
          SELECT lvl + 1
                ,text
            FROM error_set
           WHERE lvl < 3)
        SELECT lvl
              ,CASE lvl
                 WHEN 1 THEN
                  substr(text, instr(text, 'at') + 4, (instr(text, '.') - (instr(text, 'at') + 4)))
                 WHEN 2 THEN
                  substr(text, instr(text, '.') + 1, (instr(text, '",') - (instr(text, '.') + 1)))
                 WHEN 3 THEN
                  substr(text, instr(text, 'line') + 5)
               END AS text
          FROM error_set;*/
      null;
    end; 

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
         /* record_logs('--Backtrace--');
          record_logs(dbms_utility.format_error_backtrace);
          record_logs('--Text error--');
          record_logs(dbms_utility.format_error_stack);*/
          dbms_output.put_line('--Backtrace--');
          dbms_output.put_line(dbms_utility.format_error_backtrace);
          dbms_output.put_line('--Text error--');
          dbms_output.put_line(dbms_utility.format_error_stack); 
      END;
    END LOOP;
  
  END grants_to_owner;

END pkg_admin_setting;
/
