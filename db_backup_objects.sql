create table DB_BACKUP_OBJECTS
(
  versions_obj    NUMBER not null,
  createdate      DATE default sysdate,
  owner_obj       VARCHAR2(256) not null,
  type_obj        VARCHAR2(256) not null,
  name_obj        VARCHAR2(256) not null,
  description_obj CLOB
)
/

alter table DB_BACKUP_OBJECTS
  add constraint OBJ_PK primary key (VERSIONS_OBJ, OWNER_OBJ, TYPE_OBJ, NAME_OBJ)
/
