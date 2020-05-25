/* EXAMPLE HOW IT WORKS ON SCHEMA SOLUTION_ROOT */
WITH tab_src AS (SELECT LAG(keyid, 1, 0) OVER (order by createdate) prev_id
                        ,T.*
                   FROM solution_root.db_backup_objects t
                  WHERE t.owner_obj = '&owner'
                    AND t.name_obj = '&obj_name'
                    AND t.type_obj = '&obj_type')
     , tab_clobs AS (SELECT t1.data_obj AS FIRST
                            , t2.data_obj AS LAST
                                FROM tab_src t1
                                     ,tab_src t2 
                               WHERE t1.prev_id = t2.keyid
                                 AND t1.createdate = (SELECT MAX(createdate)
                                                        FROM tab_src))     
     , tab_clobs_old AS (SELECT (SELECT ts.data_obj
                                FROM tab_src ts
                               WHERE ts.createdate = (SELECT MAX(createdate)
                                                       FROM tab_src)) AS LAST
                             ,(SELECT ts.data_obj
                                FROM tab_src ts
                               WHERE ts.createdate = (SELECT MIN(createdate)
                                                       FROM tab_src)) AS FIRST
                             ,(SELECT ts.data_obj
                                FROM tab_src ts
                               WHERE ts.createdate = (SELECT MIN(createdate)
                                                       FROM tab_src)) AS FIRST
                       FROM dual)
     , tab_result AS (SELECT a.*
                        FROM tab_clobs,
                             TABLE(clob_compare.compare_line_by_line(tab_clobs.last, tab_clobs.first)) a)
SELECT *
  FROM tab_result                                                       
 WHERE status = '<<<<>>>>'; 



