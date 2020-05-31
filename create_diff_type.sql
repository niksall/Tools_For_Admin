CREATE OR REPLACE TYPE t_differences AS OBJECT
(
  old_line_number NUMBER,
  old_file        VARCHAR2(4000),
  status          VARCHAR2(20),
  new_line_number NUMBER,
  new_file        VARCHAR2(4000)
)
/
CREATE OR REPLACE TYPE t_differences_array as table of t_differences
/
CREATE OR REPLACE TYPE t_varchar2_array IS TABLE OF VARCHAR2(4000)
/
