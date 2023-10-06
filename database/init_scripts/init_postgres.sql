-- rbac_ddl

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA pg_catalog;
CREATE SCHEMA IF NOT EXISTS RBAC;

DROP TABLE IF EXISTS rbac.rbac_namespaces_path CASCADE;
CREATE TABLE rbac.rbac_namespaces_path
(
  namespace VARCHAR(255) UNIQUE NOT NULL,
  namespace_path LTREE NOT NULL,
  namespace_array VARCHAR[],
  CONSTRAINT rbac_namespaces_path_pk PRIMARY KEY (namespace)
);
CREATE INDEX namespaces_path_idx1 ON rbac.rbac_namespaces_path USING BTREE (namespace_path);
CREATE INDEX namespaces_path_idx2 ON rbac.rbac_namespaces_path USING GIST (namespace_path);
CREATE INDEX namespaces_path_idx3 ON rbac.rbac_namespaces_path USING GIN (namespace_array);

DROP TABLE IF EXISTS rbac.rbac_policies CASCADE;
CREATE TABLE rbac.rbac_policies
(
  resource_id VARCHAR(518) NOT NULL,  -- 255 / 6 / 255 = 518  (policy = 6)
  namespace VARCHAR(255) NOT NULL,
  namespace_path LTREE NOT NULL,
  assignee VARCHAR(527) NOT NULL,     --255 / 15 / 255 = 527  (service-account = 15 chars, ldap will be smaller)
  assignee_type CHAR(1) NOT NULL,
  required_groups JSONB,
  role VARCHAR(516) NOT NULL,         -- 255 / 4 / 255 = 516 (role = 4)
  CONSTRAINT policies_fk_namespace FOREIGN KEY(namespace) REFERENCES rbac.rbac_namespaces_path(namespace)
);

CREATE UNIQUE INDEX unique_policies_pk              ON rbac.rbac_policies USING BTREE (resource_id, namespace, assignee, assignee_type, required_groups, role);
CREATE INDEX rbac_policies_resource_id_idx          ON rbac.rbac_policies USING BTREE (resource_id);
CREATE INDEX rbac_policies_idx2                     ON rbac.rbac_policies USING BTREE (assignee, assignee_type);
CREATE INDEX rbac_policies_idx3                     ON rbac.rbac_policies USING BTREE (role);
CREATE INDEX rbac_policies_idx4                     ON rbac.rbac_policies USING BTREE (assignee);
CREATE INDEX rbac_policies_namespace_path_gist_idx  ON rbac.rbac_policies USING GIST (namespace_path);
CREATE INDEX rbac_policies_namespace_path_btree_idx ON rbac.rbac_policies USING BTREE (namespace_path);
--The only way to make the unique index a primary key. the difference is PK doesn't allow a null and unique index does
ALTER TABLE rbac.rbac_policies ADD CONSTRAINT unique_policies_pk UNIQUE USING INDEX unique_policies_pk;

DROP TABLE IF EXISTS rbac.rbac_roles CASCADE;
CREATE TABLE rbac.rbac_roles
(
  resource_id VARCHAR(516) NOT NULL,  -- 255 / 4 / 255 = 516  (role = 4)
  kind VARCHAR(255) NOT NULL,
  kind_name VARCHAR(255),
  allow JSONB NOT NULL,
  attributes JSONB
);

CREATE UNIQUE INDEX unique_roles_pk      ON rbac.rbac_roles USING BTREE (resource_id, kind, kind_name, allow, attributes);
CREATE INDEX rbac_roles_kin_kindname_idx ON rbac.rbac_roles USING BTREE (kind, kind_name);
CREATE INDEX rbac_roles_allow_idx        ON rbac.rbac_roles USING GIN (allow);
CREATE INDEX rbac_roles_attributes_idx   ON rbac.rbac_roles USING GIN (attributes);
--The only way to make the unique index a primary key. the difference is PK doesn't allow a null and unique index does
ALTER TABLE rbac.rbac_roles ADD CONSTRAINT unique_roles_pk UNIQUE USING INDEX unique_roles_pk;

-- core_ddl

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA pg_catalog;
CREATE SCHEMA IF NOT EXISTS core;

DROP SEQUENCE IF EXISTS core.offset_seq;
CREATE SEQUENCE core.offset_seq INCREMENT BY 2 START 1;    -- leaving a gap for manual adjustment if ever needed

DROP TABLE IF EXISTS core.resource CASCADE;
CREATE TABLE IF NOT EXISTS core.resource
(
  resource_id VARCHAR(767) NOT NULL,
  namespace VARCHAR(255) NOT NULL,
  kind VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  version SMALLINT NOT NULL DEFAULT 1,
  uuid VARCHAR(36) NOT NULL,
  event_id VARCHAR(36),
  created BIGINT NOT NULL DEFAULT 0,
  created_by VARCHAR(255) NOT NULL,
  updated BIGINT NOT NULL DEFAULT 0,
  updated_by VARCHAR(255),
  deleted BIGINT NOT NULL DEFAULT 0,
  deleted_by VARCHAR(255),
  annotations HSTORE,
  labels HSTORE,
  parent_resource_id VARCHAR(800),
  spec JSONB NOT NULL,
  status JSONB NOT NULL,
  lifecycle_action VARCHAR(10),
  lifecycle_requested_by VARCHAR(255),
  lifecycle_request_source VARCHAR(255),
  lifecycle_started BIGINT NOT NULL DEFAULT 0,
  lifecycle_completed BIGINT NOT NULL DEFAULT 0,
  lifecycle_uuid VARCHAR(36),
  lifecycle_context JSONB,
  agents_status HSTORE,
  ready BOOLEAN NOT NULL DEFAULT TRUE,
  pending BOOLEAN NOT NULL DEFAULT FALSE,
  metrics JSONB,
  parent_seq INTEGER,
  offset_value BIGINT NOT NULL,
  namespace_path LTREE NOT NULL,
  update_count INTEGER,
  history BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT resource_pk PRIMARY KEY (resource_id),
  CONSTRAINT resource_fk_namespaces_path FOREIGN KEY(namespace) REFERENCES rbac.rbac_namespaces_path(namespace)
) PARTITION BY HASH (resource_id);

CREATE TABLE core.resource_part0  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 0);
CREATE TABLE core.resource_part1  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 1);
CREATE TABLE core.resource_part2  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 2);
CREATE TABLE core.resource_part3  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 3);
CREATE TABLE core.resource_part4  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 4);
CREATE TABLE core.resource_part5  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 5);
CREATE TABLE core.resource_part6  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 6);
CREATE TABLE core.resource_part7  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 7);
CREATE TABLE core.resource_part8  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 8);
CREATE TABLE core.resource_part9  PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 9);
CREATE TABLE core.resource_part10 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 10);
CREATE TABLE core.resource_part11 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 11);
CREATE TABLE core.resource_part12 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 12);
CREATE TABLE core.resource_part13 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 13);
CREATE TABLE core.resource_part14 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 14);
CREATE TABLE core.resource_part15 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 15);
CREATE TABLE core.resource_part16 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 16);
CREATE TABLE core.resource_part17 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 17);
CREATE TABLE core.resource_part18 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 18);
CREATE TABLE core.resource_part19 PARTITION OF core.resource FOR VALUES WITH (modulus 20, remainder 19);

CREATE INDEX resource_offset_value_idx         ON core.resource USING BTREE (offset_value);
CREATE INDEX resource_uuid_idx                 ON core.resource USING BTREE (uuid);
CREATE INDEX resource_labels_idx               ON core.resource USING GIN (labels);
CREATE INDEX resource_annotations_idx          ON core.resource USING GIN (annotations);
CREATE INDEX resource_agents_status_idx        ON core.resource USING GIN (agents_status);
CREATE INDEX resource_status_idx               ON core.resource USING GIN (status);
CREATE INDEX resource_id_idx                   ON core.resource USING BTREE (namespace, kind, name);
CREATE INDEX resource_namespace_path_gist_idx  ON core.resource USING GIST (namespace_path);
CREATE INDEX resource_kind_name_partial_idx    ON core.resource (kind, name) WHERE kind = 'namespace';
CREATE INDEX resource_parent_resource_id_idx   ON core.resource USING BTREE (parent_resource_id);
CREATE INDEX resource_composite_pk_idx         ON core.resource  USING BTREE (resource_id, namespace, kind);

DROP TABLE IF EXISTS core.history CASCADE;
CREATE TABLE IF NOT EXISTS core.history
(
  resource_id VARCHAR(767) NOT NULL,
  namespace VARCHAR(255) NOT NULL,
  kind VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  version SMALLINT NOT NULL DEFAULT 1,
  uuid VARCHAR(36) NOT NULL,
  event_id VARCHAR(36),
  created BIGINT NOT NULL DEFAULT 0,
  created_by VARCHAR(255) NOT NULL,
  updated BIGINT NOT NULL DEFAULT 0,
  updated_by VARCHAR(255),
  deleted BIGINT NOT NULL DEFAULT 0,
  deleted_by VARCHAR(255),
  annotations HSTORE,
  labels HSTORE,
  parent_resource_id VARCHAR(800),
  spec JSONB NOT NULL,
  status JSONB NOT NULL,
  lifecycle_action VARCHAR(10),
  lifecycle_requested_by VARCHAR(255),
  lifecycle_request_source VARCHAR(255),
  lifecycle_started BIGINT NOT NULL DEFAULT 0,
  lifecycle_completed BIGINT NOT NULL DEFAULT 0,
  lifecycle_uuid VARCHAR(36),
  lifecycle_context JSONB,
  agents_status HSTORE,
  ready BOOLEAN NOT NULL DEFAULT TRUE,
  pending BOOLEAN NOT NULL DEFAULT FALSE,
  metrics JSONB,
  offset_value BIGINT NOT NULL,
  seq INTEGER NOT NULL,
  parent_seq INTEGER NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  aud_dml_op CHAR(1) NOT NULL CHECK (aud_dml_op = 'I' OR aud_dml_op = 'D' OR aud_dml_op='U'),
  aud_dml_ts TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  aud_dml_by VARCHAR(255),
  removed BOOLEAN NOT NULL DEFAULT FALSE,
  namespace_path ltree NOT NULL,
  trn_id INT NOT NULL,
  history BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT history_pk PRIMARY KEY (uuid, history, removed, offset_value, aud_dml_ts)
) PARTITION BY LIST (history);

CREATE TABLE core.history_plisthist PARTITION OF core.history FOR VALUES IN (true)
  PARTITION BY HASH (UUID);

CREATE TABLE core.history_plisthist_part0  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 0);
CREATE TABLE core.history_plisthist_part1  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 1);
CREATE TABLE core.history_plisthist_part2  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 2);
CREATE TABLE core.history_plisthist_part3  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 3);
CREATE TABLE core.history_plisthist_part4  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 4);
CREATE TABLE core.history_plisthist_part5  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 5);
CREATE TABLE core.history_plisthist_part6  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 6);
CREATE TABLE core.history_plisthist_part7  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 7);
CREATE TABLE core.history_plisthist_part8  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 8);
CREATE TABLE core.history_plisthist_part9  PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 9);
CREATE TABLE core.history_plisthist_part10 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 10);
CREATE TABLE core.history_plisthist_part11 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 11);
CREATE TABLE core.history_plisthist_part12 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 12);
CREATE TABLE core.history_plisthist_part13 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 13);
CREATE TABLE core.history_plisthist_part14 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 14);
CREATE TABLE core.history_plisthist_part15 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 15);
CREATE TABLE core.history_plisthist_part16 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 16);
CREATE TABLE core.history_plisthist_part17 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 17);
CREATE TABLE core.history_plisthist_part18 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 18);
CREATE TABLE core.history_plisthist_part19 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 19);
CREATE TABLE core.history_plisthist_part20 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 20);
CREATE TABLE core.history_plisthist_part21 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 21);
CREATE TABLE core.history_plisthist_part22 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 22);
CREATE TABLE core.history_plisthist_part23 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 23);
CREATE TABLE core.history_plisthist_part24 PARTITION OF core.history_plisthist FOR VALUES WITH (modulus 25, remainder 24);

CREATE TABLE core.history_plistaud PARTITION OF core.history FOR VALUES IN (false)
  PARTITION BY RANGE (aud_dml_ts);

CREATE TABLE core.history_plistaud_testing PARTITION OF core.history_plistaud FOR VALUES FROM ('2022-01-01 00:00:00') TO ('2050-01-01 00:00:00');

CREATE INDEX history_offset_value_idx         ON core.history USING BTREE (offset_value);
CREATE INDEX history_uuid_idx                 ON core.history USING BTREE (uuid);
CREATE INDEX history_resource_id_idx          ON core.history USING BTREE (resource_id);
CREATE INDEX history_namespace_path_gist_idx  ON core.history USING GIST (namespace_path);

DROP TABLE IF EXISTS core.agent CASCADE;
CREATE TABLE IF NOT EXISTS core.agent
(
  resource_id VARCHAR(767) NOT NULL,
  namespace VARCHAR(255) NOT NULL,
  kind VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  version SMALLINT NOT NULL DEFAULT 1,
  uuid VARCHAR(36) NOT NULL,
  event_id VARCHAR(36),
  created BIGINT NOT NULL DEFAULT 0,
  created_by VARCHAR(255) NOT NULL,
  updated BIGINT NOT NULL DEFAULT 0,
  updated_by VARCHAR(255),
  deleted BIGINT NOT NULL DEFAULT 0,
  deleted_by VARCHAR(255),
  annotations HSTORE,
  labels HSTORE,
  parent_resource_id VARCHAR(800),
  spec JSONB NOT NULL,
  status JSONB NOT NULL,
  lifecycle_action VARCHAR(10),
  lifecycle_requested_by VARCHAR(255),
  lifecycle_request_source VARCHAR(255),
  lifecycle_started BIGINT NOT NULL DEFAULT 0,
  lifecycle_completed BIGINT NOT NULL DEFAULT 0,
  lifecycle_uuid VARCHAR(36),
  lifecycle_context JSONB,
  agents_status HSTORE,
  ready BOOLEAN NOT NULL DEFAULT TRUE,
  pending BOOLEAN NOT NULL DEFAULT FALSE,
  metrics JSONB,
  offset_value BIGINT NOT NULL,
  CONSTRAINT agent_resource_pk PRIMARY KEY (resource_id)
);

CREATE INDEX agent_uuid_idx ON core.agent USING BTREE (uuid);
CREATE INDEX agent_spec_idx ON core.agent USING GIN (spec);

DROP TABLE IF EXISTS core.kind CASCADE;
CREATE TABLE IF NOT EXISTS core.kind
(
  resource_id VARCHAR(767) NOT NULL,
  namespace VARCHAR(255) NOT NULL,
  kind VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  version SMALLINT NOT NULL DEFAULT 1,
  uuid VARCHAR(36) NOT NULL,
  event_id VARCHAR(36),
  created BIGINT NOT NULL DEFAULT 0,
  created_by VARCHAR(255) NOT NULL,
  updated BIGINT NOT NULL DEFAULT 0,
  updated_by VARCHAR(255),
  deleted BIGINT NOT NULL DEFAULT 0,
  deleted_by VARCHAR(255),
  annotations HSTORE,
  labels HSTORE,
  parent_resource_id VARCHAR(800),
  spec JSONB NOT NULL,
  status JSONB NOT NULL,
  lifecycle_action VARCHAR(10),
  lifecycle_requested_by VARCHAR(255),
  lifecycle_request_source VARCHAR(255),
  lifecycle_started BIGINT NOT NULL DEFAULT 0,
  lifecycle_completed BIGINT NOT NULL DEFAULT 0,
  lifecycle_uuid VARCHAR(36),
  lifecycle_context JSONB,
  agents_status HSTORE,
  ready BOOLEAN NOT NULL DEFAULT TRUE,
  pending BOOLEAN NOT NULL DEFAULT FALSE,
  metrics JSONB,
  offset_value BIGINT NOT NULL,
  CONSTRAINT kind_resource_pk PRIMARY KEY (resource_id)
);

CREATE INDEX kind_uuid_idx ON core.kind USING BTREE (uuid);
CREATE INDEX kind_spec_idx ON core.kind USING GIN (spec);

DROP TABLE IF EXISTS core.quota_definition CASCADE;
CREATE TABLE core.quota_definition
(
  uuid VARCHAR(36) NOT NULL,              -- resource uuid
  description VARCHAR(1024) NOT NULL,     -- resource description
  CONSTRAINT quota_definition_pk PRIMARY KEY (uuid)
);
DROP TABLE IF EXISTS core.quota CASCADE;
CREATE TABLE core.quota
(
  id SERIAL PRIMARY KEY,
  uuid VARCHAR(36) NOT NULL,                         -- resource uuid (foreign key to core.quota_definition)
  namespace VARCHAR(255) NOT NULL,        -- resource and quota namespace are the same
  name VARCHAR(255) NOT NULL,                        -- quota name (not resource name)
  scope SMALLINT NOT NULL DEFAULT 0,                 -- 0 = apply here, 1 = child, 2 = grand-child, etc
  type VARCHAR(16) NOT NULL DEFAULT 'limit',         -- limit (default) or subscription
  aggregation VARCHAR(16) NOT NULL DEFAULT 'count',  -- count (default), sum, max
  constraints JSONB NOT NULL,
  message VARCHAR(1024) NOT NULL,
  value_attribute_path VARCHAR(1024),
  value_number_default INTEGER,
  comparison_attribute_path VARCHAR(1024),
  filter_kinds VARCHAR[] NOT NULL,
  filter_names VARCHAR[],
  filter_attributes JSONB,
  allow_actions VARCHAR[],
  block_actions VARCHAR[],
  CONSTRAINT fk_quota_definition FOREIGN KEY(uuid) REFERENCES core.quota_definition(uuid) ON DELETE CASCADE
);
CREATE INDEX quota_name_idx  ON core.quota USING BTREE (name);
CREATE INDEX quota_type_idx  ON core.quota USING BTREE (type);
CREATE INDEX quota_kinds_idx ON core.quota USING GIN (filter_kinds, filter_names);
CREATE INDEX quota_namespace_idx ON core.quota USING BTREE (namespace);

DROP TABLE IF EXISTS core.resource_group CASCADE;
CREATE TABLE IF NOT EXISTS core.resource_group
(
  name VARCHAR(255) UNIQUE NOT NULL,
  uuid VARCHAR(36) NOT NULL,
  description VARCHAR(1024) NOT NULL,
  type CHAR(3) NOT NULL,                  --  APP, IND, STD
  groups JSONB NOT NULL,
  annotations HSTORE,
  labels HSTORE,
  alias VARCHAR(255),
  application VARCHAR(255),
  ask_id VARCHAR(15),                     -- UHGWM001-123456 or AIDE_1234567
  gl_bu VARCHAR(10),
  gl_ou VARCHAR(10),
  gl_loc VARCHAR(10),
  gl_dept VARCHAR(10),
  unfunded BOOLEAN,
  chargeback_group VARCHAR(255),
  CONSTRAINT resource_group_pk PRIMARY KEY (name)
);

CREATE INDEX resource_group_uuid_idx        ON core.resource_group USING BTREE (uuid);
CREATE INDEX resource_group_type_idx        ON core.resource_group USING BTREE (type);
CREATE INDEX resource_group_alias_idx       ON core.resource_group USING BTREE (alias);
CREATE INDEX resource_group_gl_idx          ON core.resource_group USING BTREE (gl_bu, gl_ou, gl_loc, gl_dept);
CREATE INDEX resource_group_ask_idx         ON core.resource_group USING BTREE (ask_id);
CREATE INDEX resource_group_dept_idx        ON core.resource_group USING BTREE (gl_dept);
CREATE INDEX resource_group_unfunded_idx    ON core.resource_group USING BTREE (unfunded);
CREATE INDEX resource_group_chargeback_idx  ON core.resource_group USING BTREE (chargeback_group);
CREATE INDEX resource_group_labels_idx      ON core.resource USING GIN (labels);
CREATE INDEX resource_group_annotations_idx ON core.resource USING GIN (annotations);

DROP TABLE IF EXISTS core.resource_group_access CASCADE;
CREATE TABLE core.resource_group_access
(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  access_group VARCHAR(255) NOT NULL,
  assignee VARCHAR(527) NOT NULL,
  assignee_type VARCHAR(1) NOT NULL
);
CREATE UNIQUE INDEX rg_access_group_idx ON core.resource_group_access USING BTREE (name, access_group, assignee);

DROP TABLE IF EXISTS core.service_account CASCADE;
CREATE TABLE IF NOT EXISTS core.service_account
(
  resource_id VARCHAR(767) NOT NULL,
  namespace VARCHAR(255) NOT NULL,
  kind VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  version SMALLINT NOT NULL DEFAULT 1,
  uuid VARCHAR(36) NOT NULL,
  event_id VARCHAR(36),
  created BIGINT NOT NULL DEFAULT 0,
  created_by VARCHAR(255) NOT NULL,
  updated BIGINT NOT NULL DEFAULT 0,
  updated_by VARCHAR(255),
  deleted BIGINT NOT NULL DEFAULT 0,
  deleted_by VARCHAR(255),
  annotations HSTORE,
  labels HSTORE,
  parent_resource_id VARCHAR(800),
  spec JSONB NOT NULL,
  status JSONB NOT NULL,
  lifecycle_action VARCHAR(10),
  lifecycle_requested_by VARCHAR(255),
  lifecycle_request_source varchar(255) ,
  lifecycle_started BIGINT NOT NULL DEFAULT 0,
  lifecycle_completed BIGINT NOT NULL DEFAULT 0,
  lifecycle_uuid VARCHAR(36),
  lifecycle_context JSONB,
  agents_status HSTORE,
  ready BOOLEAN NOT NULL DEFAULT TRUE,
  pending BOOLEAN NOT NULL DEFAULT FALSE,
  metrics JSONB,
  offset_value BIGINT NOT NULL,
  CONSTRAINT service_account_resource_pk PRIMARY KEY (resource_id)
);

CREATE INDEX service_account_uuid_idx         ON core.kind USING BTREE (uuid);
CREATE INDEX service_account_spec_idx         ON core.kind USING GIN (spec);

DROP TABLE IF EXISTS core.relationship CASCADE;
CREATE TABLE IF NOT EXISTS core.relationship (
  id BIGSERIAL NOT NULL,
  r1_id varchar(767) NOT NULL,                -- parent / referenced
  r2_id varchar(767) NOT NULL,                -- child / dependent
  prop jsonb NOT NULL,                        -- relationship properties, including "relation", "alias" (optional)
                                              -- 'relation' options are: 'pc', '1w', '2w'
  CONSTRAINT relationship_pk PRIMARY KEY (id)
);
CREATE UNIQUE INDEX unique_relationship_pk ON core.relationship USING BTREE (r1_id, r2_id);
CREATE INDEX relationship_relation1_idx    ON core.relationship(r1_id , COALESCE((prop ->> 'relation'::text), 'pc'));
CREATE INDEX relationship_relation2_idx    ON core.relationship(r2_id , COALESCE((prop ->> 'relation'::text), 'pc'));
CREATE INDEX relationship_prop_idx         ON core.relationship USING gin (prop);

-- core.resource triggers

CREATE OR REPLACE FUNCTION core.resource_constraint_check_t() RETURNS TRIGGER AS
'
  DECLARE
    parent_exists_ bool;
    offset_value_ bigint;
    uuid_exists bool;
    offset_exists bool;
  BEGIN
    -- resource table constraints for uuid and offset_value
   select cast(nextval( ''core.offset_seq'') as bigint) into offset_value_;
   new.offset_value = offset_value_;

   if TG_OP = ''INSERT'' then
     if new.parent_seq is not null then
       raise EXCEPTION ''% NEW.parent_seq should be NULL for INSERT'', new.resource_id;
       return null;
     else
       return new;
     end if;
   end if;

   if TG_OP = ''UPDATE'' then
     if new.resource_id != old.resource_id then
       raise EXCEPTION ''ERROR: resource_id is restricted for update'';
       return null;
     end if;
     if new.namespace != old.namespace then
       raise EXCEPTION ''ERROR: namespace is restricted for update'';
       return null;
     end if;
     if new.kind != old.kind then
       raise EXCEPTION ''ERROR: kind is restricted for update'';
       return null;
     end if;
     if new.name != old.name then
       raise EXCEPTION ''ERROR: name is restricted for update'';
       return null;
     end if;
     if new.namespace_path != old.namespace_path then
       raise EXCEPTION ''ERROR: namespace_path is restricted for update'';
       return null;
     end if;

     select case when count(*) = 0 then false else true end into parent_exists_
       from core.history
       where exists (select 1 from core.history where uuid = new.uuid and removed = false and seq = coalesce(new.parent_seq,0));
     if parent_exists_ then
       return new;
     else
       raise debug ''% parent_seq'', new.parent_seq;
       raise EXCEPTION ''% % NEW.parent_seq is not valid'', new.resource_id, new.parent_seq;
     end if;
   end if;

   return null;
  END;
'
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS resource_constraint_check_trigger ON core.resource;
CREATE TRIGGER resource_constraint_check_trigger BEFORE INSERT OR UPDATE ON core.resource
  FOR EACH ROW EXECUTE PROCEDURE core.resource_constraint_check_t();

CREATE OR REPLACE FUNCTION core.resource_insert_t() RETURNS TRIGGER AS
'
  DECLARE
    cur_time bigint;
    exists_ bool;
    aud_removed_ bool;
    r_t record;
    p_t record;
    q_t record;
    rg_t record;
    p_namespace_ varchar;
    p_namespace_path_ ltree;
    p_namespace_array_ varchar[];
    c_namespace_ varchar;
    c_namespace_array_ varchar[] := ''{}'';
    c_namespace_path_ ltree;
    root_ns_f_ bool;
    trn_id integer;
    current_ts TIMESTAMP;
    chargeback varchar;
  BEGIN
    select into current_ts (current_timestamp)::TIMESTAMP;
    select into cur_time cast(to_char(current_ts,''yyyymmddhhmissms'') as bigint);
    select into trn_id cast(cast(pg_current_xact_id()::xid as text) as int);

    -- prevent adding new history record not starting from active, non-deleted (aud_removed) history record for this resource_id
    select case when count(*) = 0 then false else true end,
           max(case when removed = true then 1 else 0 end)
      into exists_, aud_removed_
      from core.history
      where uuid = new.uuid
           and history is true
           and offset_value = (select coalesce(max(offset_value),0) from core.history where uuid = new.uuid and history is true);

     if exists_ and not aud_removed_ then
       raise exception ''% CANNOT add history record for INSERT for active tree'', new.resource_id;
       return null;
     end if;

     -- for every resource, check that namespace (and therefore namespace_path) exists
     select namespace, namespace_path, namespace_array into p_namespace_, p_namespace_path_, p_namespace_array_
       from rbac.rbac_namespaces_path where namespace = new.namespace limit 1;
     if not found then
       c_namespace_path_ := text2ltree(replace(replace(new.namespace,''-'',''___''),''.'',''_''));
       c_namespace_array_ := array_append(p_namespace_array_, new.namespace);
       raise debug ''c_namespace_path_ = %'' , c_namespace_path_;
       raise debug ''c_namespace_array_ = %'' , c_namespace_array_;
       insert into rbac.rbac_namespaces_path(namespace, namespace_path, namespace_array) values (new.namespace, c_namespace_path_, c_namespace_array_);
       p_namespace_path_ := c_namespace_path_;
     end if;

    -- partition the ''namespace'' kind to its own table
     if new.kind = ''namespace'' then

       if new.namespace != new.name then

         -- since this resource is a namespace itself, update namespace path accordingly
         c_namespace_path_ := p_namespace_path_ || text2ltree(replace(replace(new.name,''-'',''___''),''.'',''_''));
         c_namespace_array_ := array_append(p_namespace_array_, new.name);
         raise debug ''c_namespace_path_ = %'', c_namespace_path_;
         insert into rbac.rbac_namespaces_path(namespace, namespace_path, namespace_array) values (new.name, c_namespace_path_, c_namespace_array_);
         p_namespace_path_ := c_namespace_path_;

         -- get the chargeback group to insert into core.resource_groups
         if (select new.spec ->> ''resourceGroupType'') is not null then
            chargeback := (select distinct rg.chargeback_group from core.resource_group rg
                            where rg.name in (select unnest(p_namespace_array_)));
            if chargeback is null then
                if (select new.spec ->> ''resourceGroupType'') != ''IND'' then
                    chargeback := lower(new.spec ->> ''askId'');
                else
                    chargeback := new.name;
                end if;
            end if;
         end if;

         -- if a resource group, add to the resource group table, the core.resource_group table should only contain resource groups
         delete from core.resource_group where name = new.name;
         insert into core.resource_group(name, uuid, description, annotations, labels, type, groups, alias, application, ask_id, gl_bu, gl_ou, gl_loc, gl_dept, unfunded, chargeback_group)
           select n.name, n.uuid, n.spec ->> ''description'' as description, n.annotations, n.labels, substring(upper(n.spec ->> ''resourceGroupType''), 1, 3) as type,
                n.spec -> ''namespaceGroups'' -> ''groups'' as groups, n.spec ->> ''alias'' as alias, n.spec ->> ''application'' as application, n.spec ->> ''askId'' as ask_id, n.spec ->> ''businessUnit'' as gl_bu,
                n.spec ->> ''operatingUnit'' as gl_ou, upper(n.spec ->> ''location'') as gl_loc, n.spec ->> ''departmentId'' as gl_dept,
                cast(n.spec -> ''funding'' ->> ''notFunded'' as boolean) as unfunded, chargeback
             from (select new.name, new.uuid, new.annotations, new.labels, new.spec) n
             where n.spec ->> ''resourceGroupType'' is not null;

         delete from core.resource_group_access where name = new.name;
         for rg_t in (
            with access_groups as (
                select name, access->''key'' as access_group, (access -> ''value'')::jsonb -> ''users'' as users, (access -> ''value'')::jsonb -> ''groups'' as groups from
                	(select name, hstore(jsonb_each(n.spec -> ''namespaceGroups'' -> ''groups'')) as access from (select new.name, new.spec) n
                	    where n.spec ->> ''resourceGroupType'' is not null
                	) a
            ), insert_values as (
            	select name, access_group, jsonb_array_elements_text(users) as assignee, ''U'' as assignee_type from access_groups
            	union
            	select name, access_group, jsonb_array_elements_text(groups) as assignee, ''G'' as assignee_type from access_groups
            )
             select name, access_group, assignee, assignee_type from insert_values
         ) loop
         insert into core.resource_group_access(name, access_group, assignee, assignee_type)
            select rg_t.name, rg_t.access_group, rg_t.assignee, rg_t.assignee_type;
         end loop;

       end if;

     end if;

     -- read as needed the namespace path
     if  p_namespace_path_ is null then
       select namespace, namespace_path, namespace_array into p_namespace_, p_namespace_path_, p_namespace_array_
         from rbac.rbac_namespaces_path where namespace = new.namespace limit 1;
       raise debug ''before history <<<< p_namespace_path_ %'', p_namespace_path_;
       if not found then
         raise exception ''% namespace has not been defined yet, so cannot INSERT record'', new.namespace;
       end if;
     end if;

     -- add record to history table - NOTE: create (insert) is always significant, whether or not the new.history is set
     raise debug ''before history p_namespace_path_ %'', p_namespace_path_;
     if nlevel(p_namespace_path_) > 0 or p_namespace_path_ is not null then
       insert into core.history (
              history, namespace_path, resource_id,     namespace,     kind,     name,     version,     uuid,     event_id,     created,     created_by,     updated,     updated_by,     deleted,     deleted_by,     annotations,     labels,     parent_resource_id,     spec,     status,     lifecycle_action,  lifecycle_requested_by, lifecycle_request_source,   lifecycle_started,     lifecycle_completed,     lifecycle_uuid,     lifecycle_context,     agents_status,     ready,     pending,     metrics,     offset_value, seq, parent_seq, active, aud_dml_op , aud_dml_ts, aud_dml_by, trn_id )
       values (true, p_namespace_path_, new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics, new.offset_value, 0,   0, true  ,''I'', current_ts, current_user, trn_id);
     else
       raise debug ''history c_namespace_path_ = %'', c_namespace_path_;
       raise exception ''ERROR: core.history namespace_path cannot be empty %'', new.resource_id;
     end if;

     -- for every new ROLE resource, insert record(s) into rbac.rbac_roles
     if new.kind = ''role'' then
       for r_t in (
         with rules(resource_id, rule_number, rule_) as (
           select resource_id, row_number() over (), rule_ from (
             select NEW.resource_id, jsonb_array_elements(NEW.spec -> ''rules'') as rule_
           ) as therules
         ), allow_permissions(resource_id, rule_number, allow) as (
           select resource_id, rule_number, rule_ -> ''allow''  from rules
         ), allow_kinds(resource_id, rule_number, kind) as (
           select resource_id, rule_number, jsonb_array_elements_text(case jsonb_typeof(rule_ -> ''kinds'') when ''array'' then rule_ -> ''kinds'' else ''[]'' end)  from rules
         ), allow_kind_names(resource_id, rule_number, kind_name) as (
           select resource_id, rule_number, jsonb_array_elements_text(case jsonb_typeof(rule_ -> ''names'') when ''array'' then rule_ -> ''names'' else ''[]'' end)  from rules
         ), with_attributes(resource_id, rule_number, attributes) as (
           select resource_id, rule_number,
	          case jsonb_typeof(rule_ -> ''attributes'') when ''object'' then (rule_ -> ''attributes'')::jsonb else ''{}''::jsonb end as attributes from rules
         )
         select distinct r.resource_id, k.kind::text, n.kind_name, p.allow, a.attributes
           from rules r inner join allow_permissions p on r.resource_id = p.resource_id and r.rule_number = p.rule_number
                inner join allow_kinds k on r.resource_id = k.resource_id and r.rule_number = k.rule_number
                left join allow_kind_names n on r.resource_id = n.resource_id and r.rule_number = n.rule_number
                left join  with_attributes a on r.resource_id = a.resource_id and r.rule_number = a.rule_number
       ) loop
         insert into rbac.rbac_roles(resource_id, allow, kind, kind_name, attributes)
           select  r_t.resource_id, r_t.allow, r_t.kind, r_t.kind_name, r_t.attributes;
       end loop;
      end if;

     -- for every new POLICY resource, insert record(s) into rbac.rbac_policies
     if new.kind = ''policy'' then
       for p_t in (
         with policy_spec(resource_id, namespace, assign_number, assign) as (
           select resource_id, namespace, row_number() over (), assign from (
             select t0.resource_id, t0.namespace, jsonb_array_elements(t0.spec -> ''assign'') as assign from
               (select NEW.resource_id, NEW.namespace, NEW.spec) t0
           ) theassignments
         ), users(resource_id, namespace, assign_number, username) as (
           select resource_id, namespace, assign_number, assign ->> ''username'' from policy_spec
         ), groups(resource_id, namespace, assign_number, groupname) as (
           select resource_id, namespace, assign_number, assign ->> ''group'' from policy_spec
         ), required_groups(resource_id, namespace, assign_number, required_groups) as (
           select resource_id, namespace, assign_number, assign -> ''requiredGroups'' from policy_spec
         ), roles(resource_id, namespace, assign_number, role) as (
           select resource_id, namespace, assign_number, jsonb_array_elements(roles) ->> 0 from (
             select resource_id, namespace, assign_number, (assign ->> ''roles'')::jsonb as roles from policy_spec
           ) theroles
         )
         select distinct s.resource_id, s.namespace,
                case when g.groupname is not null then g.groupname else u.username end as assignee,
                case when g.groupname is not null then ''G'' else ''U'' end as assignee_type,
                q.required_groups::jsonb as required_groups, r.role
           from policy_spec s
                left join users u on s.resource_id = u.resource_id and s.assign_number = u.assign_number
                left join groups g on s.resource_id = g.resource_id and s.assign_number = g.assign_number
                left join required_groups q on s.resource_id = q.resource_id and s.assign_number = q.assign_number
                left join roles r on s.resource_id = r.resource_id and s.assign_number = r.assign_number
       ) loop
         insert into rbac.rbac_policies(namespace_path, resource_id, namespace, assignee, assignee_type, required_groups, role)
           select  p_namespace_path_, p_t.resource_id, p_t.namespace, p_t.assignee, p_t.assignee_type, p_t.required_groups, p_t.role;
       end loop;
     end if;

     if new.kind = ''kind'' then
       delete from core.kind where resource_id = new.resource_id;
       insert into core.kind(
         resource_id, namespace, kind, name, version, uuid, event_id, created, created_by, updated, updated_by, deleted, deleted_by, annotations, labels, parent_resource_id, spec, status, lifecycle_action, lifecycle_requested_by, lifecycle_request_source, lifecycle_started, lifecycle_completed, lifecycle_uuid, lifecycle_context, agents_status, ready, pending, metrics, offset_value)
         values (new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics, new.offset_value);

     end if;

     if new.kind = ''agent'' then
        delete from core.agent where resource_id = new.resource_id;
        insert into core.agent(
	  resource_id, namespace, kind, name, version, uuid, event_id, created, created_by, updated, updated_by, deleted, deleted_by, annotations, labels, parent_resource_id, spec, status, lifecycle_action, lifecycle_requested_by, lifecycle_request_source, lifecycle_started, lifecycle_completed, lifecycle_uuid, lifecycle_context, agents_status, ready, pending, metrics, offset_value)
	  values (new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics,  new.offset_value);
     end if;

     if new.kind = ''service-account'' then
        delete from core.service_account where resource_id = new.resource_id;
        insert into core.service_account(
	  resource_id, namespace, kind, name, version, uuid, event_id, created, created_by, updated, updated_by, deleted, deleted_by, annotations, labels, parent_resource_id, spec, status, lifecycle_action, lifecycle_requested_by, lifecycle_request_source, lifecycle_started, lifecycle_completed, lifecycle_uuid, lifecycle_context, agents_status, ready, pending, metrics, offset_value)
	  values (new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics,  new.offset_value);
     end if;

      if new.kind = ''quota'' then
          delete from core.quota_definition where uuid = new.uuid;
          for q_t in (
              with quotas(resource_id, namespace, uuid, description, q_number, quota_) as (
                  select resource_id, namespace, uuid, description, row_number() over (), quota_ from (
                      select NEW.resource_id, NEW.namespace, NEW.uuid, cast(NEW.spec ->> ''description'' as varchar) as description, jsonb_array_elements(NEW.spec -> ''quotas'') as quota_
                  ) as thequotas
              )
              select resource_id, namespace, uuid, description, quota_ ->> ''name'' as name,
                 cast(quota_ ->> ''scope'' as int) as scope,
                 cast(quota_ ->> ''type'' as varchar) as type,
                 cast(quota_ ->> ''aggregation'' as varchar) as aggregation,
                 (quota_ -> ''constraints'')::jsonb as constraints,
                 quota_ ->> ''message'' as message,
                 quota_ ->> ''value'' as value_attribute_path,
                 cast(quota_ ->> ''default'' as int) as value_number_default,
                 quota_ ->> ''comparisonValue'' as comparison_attribute_path,
                 string_to_array(translate(cast(quota_ -> ''filter'' -> ''kinds'' as varchar), ''[] "'', ''''),'','')::varchar[] as filter_kinds,
                 string_to_array(translate(cast(quota_ -> ''filter'' -> ''names'' as varchar), ''[] "'', ''''),'','')::varchar[] as filter_names,
                 (quota_ -> ''filter'' -> ''attributes'')::jsonb as filter_attributes,
                 string_to_array(translate(cast(quota_ -> ''allowActions'' as varchar), ''[] "'', ''''),'','')::varchar[] as allow_actions,
                 string_to_array(translate(cast(quota_ -> ''blockActions'' as varchar), ''[] "'', ''''),'','')::varchar[] as block_actions from quotas
          ) loop
              if not exists (select uuid from core.quota_definition where uuid = q_t.uuid) then
                  insert into core.quota_definition(uuid, description)
                      select q_t.uuid, q_t.description;
              end if;
              insert into core.quota(uuid, namespace, name, scope, type, aggregation, constraints, message, value_attribute_path, value_number_default, comparison_attribute_path, filter_kinds, filter_names, filter_attributes, allow_actions, block_actions)
                  select distinct q_t.uuid, q_t.namespace, q_t.name, coalesce(q_t.scope, 0), coalesce(q_t.type, ''limit''), coalesce(q_t.aggregation, ''count''), q_t.constraints, q_t.message, q_t.value_attribute_path, q_t.value_number_default, q_t.comparison_attribute_path, q_t.filter_kinds, q_t.filter_names, q_t.filter_attributes, q_t.allow_actions, q_t.block_actions;
          end loop;
      end if;

    new.namespace_path := p_namespace_path_;

    return new;
  END;
'
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS resource_trigger_i ON core.resource;
CREATE TRIGGER resource_trigger_i BEFORE INSERT ON core.resource
  FOR EACH ROW EXECUTE PROCEDURE core.resource_insert_t();

CREATE OR REPLACE FUNCTION core.resource_delete_t() RETURNS TRIGGER AS
'
  DECLARE
    current_ts timestamp;
    seq_ integer;
    parent_seq_ integer;
    exists_ bool;
    aud_removed_ bool;
    seq_increment_ integer;
    offset_value_ bigint;
    ns record;
    trn_id integer;
    resources_exist_for_namespaces_f_ bool := true;
  BEGIN
    select into current_ts (current_timestamp)::TIMESTAMP;
    select into trn_id cast(cast(pg_current_xact_id()::xid as text) as int);

    -- block namespace deletions of non-empty namespaces
    if old.kind = ''namespace'' then
      select case when count(*) > 0 then true else false end
        into resources_exist_for_namespaces_f_
        from core.resource where namespace = old.name and kind <> ''policy'';
      if resources_exist_for_namespaces_f_ then
        raise exception ''ERROR: resources exist for namespace, deletion not allowed'';
        return null;
      end if;
    end if;

    seq_increment_ := 1;
    select coalesce(max(seq),0) max_seq,
           case when count(*) = 0 then false else true end,
           case when max(case when removed = true then 1 else 0 end) = 0 then false else true end
      into parent_seq_, exists_, aud_removed_
      from core.history
     where uuid = old.uuid
           and history is true
           and offset_value = (select coalesce(max(offset_value),0) from core.history where uuid = old.uuid and history is true);

    if not exists_ or aud_removed_ then
      raise exception ''% FAILED to add history record for DELETE'', old.resource_id;
      return null;
    else
      select cast(nextval(''core.offset_seq'') as bigint) into offset_value_;
      insert into core.history (
                 history, namespace_path,resource_id,     namespace,     kind,     name,     version,     uuid,     event_id,     created,     created_by,     updated,     updated_by,     deleted,     deleted_by,     annotations,     labels,     parent_resource_id,     spec,     status,     lifecycle_action, lifecycle_requested_by, lifecycle_request_source,   lifecycle_started,     lifecycle_completed,     lifecycle_uuid,     lifecycle_context,     agents_status,     ready,     pending,     metrics, offset_value,  seq,                          parent_seq,  active,    aud_dml_op ,    aud_dml_ts   ,  aud_dml_by, trn_id )
        values (true, old.namespace_path, old.resource_id, old.namespace, old.kind, old.name, old.version, old.uuid, old.event_id, old.created, old.created_by, old.updated, old.updated_by, old.deleted, old.deleted_by, old.annotations, old.labels, old.parent_resource_id, old.spec, old.status, old.lifecycle_action, old.lifecycle_requested_by, old.lifecycle_request_source, old.lifecycle_started, old.lifecycle_completed, old.lifecycle_uuid, old.lifecycle_context, old.agents_status, old.ready, old.pending, old.metrics, offset_value_, parent_seq_ + seq_increment_, parent_seq_, true,     ''D'', current_ts, current_user, trn_id);
      update core.history set removed = true where uuid = old.uuid and history is true;
    end if;

    if old.kind = ''role'' then
      delete from rbac.rbac_roles where resource_id = old.resource_id;
      return old;
    end if;

    if old.kind = ''policy'' then
      delete from rbac.rbac_policies where resource_id = old.resource_id;
      return old;
    end if;

    if old.kind = ''namespace'' then
      for ns in (
        select distinct namespace from rbac.rbac_namespaces_path where namespace_path ~ (''*.''||replace(replace(old.name,''-'',''___''),''.'',''_'')||''.*'')::lquery
      )
      loop
        delete from rbac.rbac_namespaces_path where namespace = ns.namespace;
      end loop;
      -- in case it is a resource group, delete it, no further check is necessary because non-resource group namespaces should not exist there anyway
      delete from core.resource_group where name = old.name;
      delete from core.resource_group_access where name = old.name;
      return old;
    end if;

    if old.kind = ''kind'' then
      delete from core.kind where resource_id = old.resource_id;
      return old;
    end if;

    if old.kind = ''agent'' then
      delete from core.agent where resource_id = old.resource_id;
      return old;
    end if;

    if old.kind = ''service-account'' then
      delete from core.service_account where resource_id = old.resource_id;
      return old;
    end if;

    if old.kind = ''quota'' then
        delete from core.quota_definition where uuid = old.uuid;
        return old;
    end if;

    return old;
  END;
'
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS resource_trigger_d ON core.resource;
CREATE TRIGGER resource_trigger_d AFTER DELETE ON core.resource
  FOR EACH ROW EXECUTE PROCEDURE core.resource_delete_t();

CREATE OR REPLACE FUNCTION core.resource_update_t() RETURNS TRIGGER AS
'
  DECLARE
    cur_time bigint;
    current_ts timestamp;
    parent_seq_  integer;
    exists_ bool;
    aud_removed_ bool;
    seq_increment_ integer;
    beginning_active_gof bigint;
    r_t record;
    p_t record;
    q_t record;
    rg_t record;
    p_namespace_path_ ltree;
    p_namespace_array_ varchar[];
    trn_id int;
    chargeback varchar;
  BEGIN
    seq_increment_ := 1;
    select into current_ts (current_timestamp)::TIMESTAMP;
    select into cur_time cast(to_char(current_ts,''yyyymmddhhmissms'') as bigint);
    select into trn_id cast(cast(pg_current_xact_id()::xid as text) as int);

    if new.history then
      -- analyze if the last record was an active record of the tree or it was a soft delete
      select coalesce(max(seq),0) max_seq,
             case when count(*) = 0 then false else true end,
             case when max(case when removed = true then 1 else 0 end) = 0 then false else true end
        into parent_seq_, exists_, aud_removed_
        from core.history
       where uuid = new.uuid
             and history is true
             and offset_value = (select coalesce(max(offset_value),0) from core.history where uuid = new.uuid and history is true);

      if not exists_ or aud_removed_ then
        raise exception ''% not found in history for UPDATE'', new.resource_id;
        return null;
      elsif new.parent_seq is null then
        insert into core.history (
                 history, namespace_path, resource_id,     namespace,     kind,     name,     version,     uuid,     event_id,     created,     created_by,     updated,     updated_by,     deleted,     deleted_by,     annotations,     labels,     parent_resource_id,     spec,     status,     lifecycle_action,  lifecycle_requested_by, lifecycle_request_source, lifecycle_started,     lifecycle_completed,     lifecycle_uuid,     lifecycle_context,     agents_status,     ready,     pending,     metrics,     offset_value, seq,                          parent_seq,  active,aud_dml_op ,    aud_dml_ts   ,  aud_dml_by,trn_id )
        values (new.history, new.namespace_path, new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics, new.offset_value, parent_seq_ + seq_increment_, parent_seq_, true,       ''U'',           current_ts, current_user, trn_id);
      elsif new.parent_seq < parent_seq_ then
        select coalesce(max(offset_value),0) into beginning_active_gof
          from core.history
         where uuid = new.uuid and removed = true;
         update core.history set active = true where seq <= new.parent_seq and uuid = new.uuid and history is true and offset_value > beginning_active_gof;
         update core.history set active = false where seq > new.parent_seq and seq <= parent_seq_ and uuid = new.uuid  and history is true and offset_value > beginning_active_gof;
         insert into core.history (
                 history, namespace_path, resource_id,     namespace,     kind,     name,     version,     uuid,     event_id,     created,     created_by,     updated,     updated_by,     deleted,     deleted_by,     annotations,     labels,     parent_resource_id,     spec,     status,     lifecycle_action,  lifecycle_requested_by, lifecycle_request_source,   lifecycle_started,     lifecycle_completed,     lifecycle_uuid,     lifecycle_context,     agents_status,     ready,     pending,     metrics,     offset_value, seq,                          parent_seq,  active,aud_dml_op ,    aud_dml_ts   ,  aud_dml_by,trn_id )
         values (new.history, new.namespace_path, new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics, new.offset_value, parent_seq_ + seq_increment_, new.parent_seq, true,       ''U'',      current_ts,    current_user, trn_id);
      end if;
    else
        -- if it is not marked for HISTORY then we write it as AUDIT record
        insert into core.history (
               history, namespace_path, resource_id,     namespace,     kind,     name,     version,     uuid,     event_id,     created,     created_by,     updated,     updated_by,     deleted,     deleted_by,     annotations,     labels,     parent_resource_id,     spec,     status,     lifecycle_action,  lifecycle_requested_by, lifecycle_request_source,   lifecycle_started,     lifecycle_completed,     lifecycle_uuid,     lifecycle_context,     agents_status,     ready,     pending,     metrics,     offset_value, seq,                          parent_seq,  active,aud_dml_op ,    aud_dml_ts   ,  aud_dml_by,trn_id )
        values (false, new.namespace_path, new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics, new.offset_value, -1, -1, false,       ''U'',      current_ts,    current_user, trn_id);
    end if;

    if new.kind = ''kind'' then
	delete from core.kind where resource_id = new.resource_id;
        insert into core.kind(
	  resource_id, namespace, kind, name, version, uuid, event_id, created, created_by, updated, updated_by, deleted, deleted_by, annotations, labels, parent_resource_id, spec, status, lifecycle_action, lifecycle_requested_by, lifecycle_request_source, lifecycle_started, lifecycle_completed, lifecycle_uuid, lifecycle_context, agents_status, ready, pending, metrics, offset_value)
	  values (new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics, new.offset_value);
    end if;

    if new.kind = ''agent'' then
	delete from core.agent where resource_id = new.resource_id;
        insert into core.agent(
	  resource_id, namespace, kind, name, version, uuid, event_id, created, created_by, updated, updated_by, deleted, deleted_by, annotations, labels, parent_resource_id, spec, status, lifecycle_action, lifecycle_requested_by, lifecycle_request_source, lifecycle_started, lifecycle_completed, lifecycle_uuid, lifecycle_context, agents_status, ready, pending, metrics,  offset_value)
	  values (new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics,  new.offset_value);
    end if;

    if new.kind = ''namespace'' then

          if (select new.spec ->> ''resourceGroupType'') is not null then
            p_namespace_array_ := (select namespace_array from rbac.rbac_namespaces_path where namespace = new.namespace);
            chargeback := (select distinct rg.chargeback_group from core.resource_group rg where rg.name in (select unnest(p_namespace_array_)));
            if chargeback is null then
                if (select new.spec ->> ''resourceGroupType'') != ''IND'' then
                    chargeback := lower(new.spec ->> ''askId'');
                else
                    chargeback := new.name;
                end if;
            end if;
            update core.resource_group r
                set chargeback_group = chargeback
                where r.name in (
                    select rg.name from core.resource_group rg
                    inner join rbac.rbac_namespaces_path rnp on rg.name = rnp.namespace and new.name = any(rnp.namespace_array)
                    where rg.name != new.name);
          end if;
         -- if a resource group, add to the resource group table, the core.resource_group table should only contain resource groups
         delete from core.resource_group where name = new.name;
         insert into core.resource_group(name, uuid, description, annotations, labels, type, groups, alias, application, ask_id, gl_bu, gl_ou, gl_loc, gl_dept, unfunded, chargeback_group)
           select n.name, n.uuid, n.spec ->> ''description'' as description, n.annotations, n.labels, substring(upper(n.spec ->> ''resourceGroupType''), 1, 3) as type,
                n.spec -> ''namespaceGroups'' -> ''groups'' as groups, n.spec ->> ''alias'' as alias, n.spec ->> ''application'' as application, n.spec ->> ''askId'' as ask_id, n.spec ->> ''businessUnit'' as gl_bu,
                n.spec ->> ''operatingUnit'' as gl_ou, upper(n.spec ->> ''location'') as gl_loc, n.spec ->> ''departmentId'' as gl_dept,
                cast(n.spec -> ''funding'' ->> ''notFunded'' as boolean) as unfunded, chargeback
             from (select new.name, new.uuid, new.annotations, new.labels, new.spec) n
             where n.spec ->> ''resourceGroupType'' is not null;

         delete from core.resource_group_access where name = new.name;
         for rg_t in (
            with access_groups as (
                select name, access->''key'' as access_group, (access -> ''value'')::jsonb -> ''users'' as users, (access -> ''value'')::jsonb -> ''groups'' as groups from
                	(select name, hstore(jsonb_each(n.spec -> ''namespaceGroups'' -> ''groups'')) as access from (select new.name, new.spec) n
                	    where n.spec ->> ''resourceGroupType'' is not null
                	) a
            ), insert_values as (
            	select name, access_group, jsonb_array_elements_text(users) as assignee, ''U'' as assignee_type from access_groups
            	union
            	select name, access_group, jsonb_array_elements_text(groups) as assignee, ''G'' as assignee_type from access_groups
            )
             select name, access_group, assignee, assignee_type from insert_values
         ) loop
         insert into core.resource_group_access(name, access_group, assignee, assignee_type)
            select rg_t.name, rg_t.access_group, rg_t.assignee, rg_t.assignee_type;
         end loop;

    end if;

    if new.kind = ''service-account'' then
      delete from core.service_account where resource_id = new.resource_id;
      insert into core.service_account(
	      resource_id, namespace, kind, name, version, uuid, event_id, created, created_by, updated, updated_by, deleted, deleted_by, annotations, labels, parent_resource_id, spec, status, lifecycle_action, lifecycle_requested_by, lifecycle_request_source, lifecycle_started, lifecycle_completed, lifecycle_uuid, lifecycle_context, agents_status, ready, pending, metrics,  offset_value)
	      values (new.resource_id, new.namespace, new.kind, new.name, new.version, new.uuid, new.event_id, new.created, new.created_by, new.updated, new.updated_by, new.deleted, new.deleted_by, new.annotations, new.labels, new.parent_resource_id, new.spec, new.status, new.lifecycle_action, new.lifecycle_requested_by, new.lifecycle_request_source, new.lifecycle_started, new.lifecycle_completed, new.lifecycle_uuid, new.lifecycle_context, new.agents_status, new.ready, new.pending, new.metrics,  new.offset_value);
    end if;

    if new.kind = ''quota'' then
        delete from core.quota_definition where uuid = new.uuid;
         for q_t in (
             with quotas(resource_id, namespace, uuid, description, q_number, quota_) as (
                 select resource_id, namespace, uuid, description, row_number() over (), quota_ from (
                     select NEW.resource_id, NEW.namespace, NEW.uuid, cast(NEW.spec ->> ''description'' as varchar) as description, jsonb_array_elements(NEW.spec -> ''quotas'') as quota_
                 ) as thequotas
             )
              select resource_id, namespace, uuid, description, quota_ ->> ''name'' as name,
                 cast(quota_ ->> ''scope'' as int) as scope,
                 cast(quota_ ->> ''type'' as varchar) as type,
                 cast(quota_ ->> ''aggregation'' as varchar) as aggregation,
                 (quota_ -> ''constraints'')::jsonb as constraints,
                 quota_ ->> ''message'' as message,
                 quota_ ->> ''value'' as value_attribute_path,
                 cast(quota_ ->> ''default'' as int) as value_number_default,
                 quota_ ->> ''comparisonValue'' as comparison_attribute_path,
                 string_to_array(translate(cast(quota_ -> ''filter'' -> ''kinds'' as varchar), ''[] "'', ''''),'','')::varchar[] as filter_kinds,
                 string_to_array(translate(cast(quota_ -> ''filter'' -> ''names'' as varchar), ''[] "'', ''''),'','')::varchar[] as filter_names,
                 (quota_ -> ''filter'' -> ''attributes'')::jsonb as filter_attributes,
                 string_to_array(translate(cast(quota_ -> ''allowActions'' as varchar), ''[] "'', ''''),'','')::varchar[] as allow_actions,
                 string_to_array(translate(cast(quota_ -> ''blockActions'' as varchar), ''[] "'', ''''),'','')::varchar[] as block_actions from quotas
         ) loop
             if not exists (select uuid from core.quota_definition where uuid = q_t.uuid) then
                 insert into core.quota_definition(uuid, description)
                     select q_t.uuid, q_t.description;
             end if;
             insert into core.quota(uuid, namespace, name, scope, type, aggregation, constraints, message, value_attribute_path, value_number_default, comparison_attribute_path, filter_kinds, filter_names, filter_attributes, allow_actions, block_actions)
                 select distinct q_t.uuid, q_t.namespace, q_t.name, coalesce(q_t.scope, 0), coalesce(q_t.type, ''limit''), coalesce(q_t.aggregation, ''count''), q_t.constraints, q_t.message, q_t.value_attribute_path, q_t.value_number_default, q_t.comparison_attribute_path, q_t.filter_kinds, q_t.filter_names, q_t.filter_attributes, q_t.allow_actions, q_t.block_actions;
         end loop;
    end if;

    if new.kind = ''role'' then
      delete from rbac.rbac_roles where resource_id = new.resource_id;
      for r_t in (
        with rules(resource_id, rule_number, rule_) as (
          select resource_id, row_number() over (), rule_ from (
            select NEW.resource_id, jsonb_array_elements(NEW.spec -> ''rules'') as rule_
          ) as therules
        ), allow_permissions(resource_id, rule_number, allow) as (
          select resource_id, rule_number, rule_ -> ''allow''  from rules
        ), allow_kinds(resource_id, rule_number, kind) as (
          select resource_id, rule_number, jsonb_array_elements_text(case jsonb_typeof(rule_ -> ''kinds'') when ''array'' then rule_ -> ''kinds'' else ''[]'' end)  from rules
        ), allow_kind_names(resource_id, rule_number, kind_name) as (
          select resource_id, rule_number, jsonb_array_elements_text(case jsonb_typeof(rule_ -> ''names'') when ''array'' then rule_ -> ''names'' else ''[]'' end)  from rules
        ), with_attributes(resource_id, rule_number, attributes) as (
          select resource_id, rule_number,
                 case jsonb_typeof(rule_ -> ''attributes'') when ''object'' then (rule_ -> ''attributes'')::jsonb else ''{}''::jsonb end as attributes
            from rules
        )
        select distinct r.resource_id, k.kind::text, n.kind_name, p.allow, a.attributes
          from rules r inner join allow_permissions p on r.resource_id = p.resource_id and r.rule_number = p.rule_number
               inner join allow_kinds k on r.resource_id = k.resource_id and r.rule_number = k.rule_number
               left join allow_kind_names n on r.resource_id = n.resource_id and r.rule_number = n.rule_number
               left join  with_attributes a on r.resource_id = a.resource_id and r.rule_number = a.rule_number
      ) loop
        insert into rbac.rbac_roles(resource_id, allow, kind, kind_name, attributes)
          select r_t.resource_id, r_t.allow, r_t.kind, r_t.kind_name, r_t.attributes;
      end loop;
    end if;

    if new.kind = ''policy'' then
    BEGIN
    select namespace_path into p_namespace_path_ from rbac.rbac_namespaces_path where namespace = new.namespace limit 1;
    if not found then
    raise EXCEPTION ''namespace not found in rbac.rbac_namesapces_path for updating policy resource_id : %'', new.resource_id;
    end if;

      delete from rbac.rbac_policies where resource_id = new.resource_id;

      for p_t in (
        with policy_spec(resource_id, namespace, assign_number, assign) as (
          select resource_id, namespace, row_number() over (), assign from (
            select t0.resource_id, t0.namespace, jsonb_array_elements(t0.spec -> ''assign'') as assign
              from (select NEW.resource_id, NEW.namespace, NEW.spec) t0
          ) theassignments
        ), users(resource_id, namespace, assign_number, username) as (
          select resource_id, namespace, assign_number, assign ->> ''username'' from policy_spec
        ), groups(resource_id, namespace, assign_number, groupname) as (
          select resource_id, namespace, assign_number, assign ->> ''group'' from policy_spec
        ), required_groups(resource_id, namespace, assign_number, required_groups) as (
          select resource_id, namespace, assign_number, assign -> ''requiredGroups'' from policy_spec
        ), roles(resource_id, namespace, assign_number, role) as (
          select resource_id, namespace, assign_number, jsonb_array_elements(roles) ->> 0 from (
            select resource_id, namespace, assign_number, (assign ->> ''roles'')::jsonb as roles from policy_spec
          ) theroles
        )
        select distinct s.resource_id, s.namespace,
               case when g.groupname is not null then g.groupname else u.username end as assignee,
               case when g.groupname is not null then ''G'' else ''U'' end as assignee_type,
               q.required_groups::jsonb as required_groups, r.role
          from policy_spec s
               left join users u on s.resource_id = u.resource_id and s.assign_number = u.assign_number
               left join groups g on s.resource_id = g.resource_id and s.assign_number = g.assign_number
               left join required_groups q on s.resource_id = q.resource_id and s.assign_number = q.assign_number
               left join roles r on s.resource_id = r.resource_id and s.assign_number = r.assign_number
      ) loop
        insert into rbac.rbac_policies(namespace_path, resource_id, namespace, assignee, assignee_type, required_groups, role)
          select  p_namespace_path_, p_t.resource_id, p_t.namespace, p_t.assignee, p_t.assignee_type, p_t.required_groups, p_t.role;
      end loop;
      END;
    end if;

    return new;
  END;
'
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS resource_trigger_u ON core.resource;
CREATE TRIGGER resource_trigger_u AFTER UPDATE ON core.resource
  FOR EACH ROW WHEN (OLD.* IS DISTINCT FROM NEW.*) EXECUTE PROCEDURE core.resource_update_t();

-- rbac_procedures

DROP TYPE IF EXISTS rbac.ResourceType CASCADE;
CREATE TYPE rbac.ResourceType AS (
    resource_id varchar,
    namespace varchar,
    kind varchar,
    name varchar,
    version smallint,
    uuid varchar,
    event_id varchar,
    created bigint,
    created_by varchar,
    updated bigint,
    updated_by varchar,
    deleted bigint,
    deleted_by varchar,
    annotations hstore,
    labels hstore,
    parent_resource_id varchar,
    spec jsonb ,
    status jsonb,
    lifecycle_action varchar,
    lifecycle_requested_by varchar,
    lifecycle_request_source varchar,
    lifecycle_started bigint,
    lifecycle_completed bigint,
    lifecycle_uuid varchar,
    lifecycle_context jsonb,
    agents_status hstore,
    ready boolean,
    pending boolean,
    metrics jsonb,
    parent_seq integer,
    offset_value bigint
);

CREATE OR REPLACE FUNCTION rbac.last_pos(text, char) RETURNS INTEGER AS
'
  select length($1) - length(regexp_replace($1, ''.*'' || $2,''''));
'
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION rbac.abac_check(Resource rbac.ResourceType, attributes_ jsonb) RETURNS BOOLEAN AS
'
  DECLARE
    attr record;
    label_ text;
    attr_value text;
    res boolean;
    attribute_exist_flag boolean;
    hs_label_value text;
    pg_path text;
    pg_match_value text;
    label_value text;
    label_exist_flag boolean;
  BEGIN
    if Resource is null or attributes_ is null or attributes_ = ''{}'' then
      return true;
    end if;
    res := true;
    for attr in (select ( jsonb_each_text(attributes_)).*  )
    loop
      raise debug ''attr.key = : %'', attr.key;
      raise debug ''attr.value = : %'', attr.value;
      attr_value := attr.value;
      if attr_value = ''='' then
        continue;
      end if;

      -- metadata.labels
      if attr.key ~ ''^\/metadata\/labels'' then
        label_ := substring(attr.key, rbac.last_pos(attr.key,''/'')+1,length(attr.key));
        label_exist_flag = exist(Resource.labels,label_);
        raise debug ''label_ = : %'', label_;
        raise debug ''label_exist_flag = : %'', label_exist_flag;
        if attr.value=''[]'' then
          raise debug ''Must NOT Exist'';
	      if label_exist_flag then
              res := res and false;
	      else
	          res := res and true;
	      end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if label_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
	    elsif defined(Resource.labels,label_) then
	       -- check if all any values from the array fit the attr.value
	       pg_match_value := ''{"value":''||attr_value ||''}'';
	       -- $.<label_name>? (@ == $value)
	       pg_path := ''$.''||label_||'' ? (@ == $value)'';
	       raise debug ''pg_path label = : %'',pg_path;
	--  BROKEN CODE:
	--       if jsonb_path_exists(hstore_to_jsonb (Resource.labels),pg_path::jsonpath,pg_match_value::jsonb) then
	--          res := res and true;
	--       else
	--          res := res and false;
	--       end if;
	-- TEMP WORKAROUND:
	        hs_label_value := Resource.labels -> label_;
            if hs_label_value = attr_value then
               res := res and true;
            else
               res := res and false;
	        end if;
	-- END WORKAROUND
	    else
	       res := res and false;
        end if;
        continue;

      -- metadata.annotations
      elsif attr.key ~ ''^\/metadata\/annotations'' then
        label_ := substring(attr.key, rbac.last_pos(attr.key,''/'')+1,length(attr.key));
        label_exist_flag = exist(Resource.annotations,label_);
        raise debug ''label_ = : %'', label_;
        raise debug ''label_exist_flag = : %'', label_exist_flag;
        if attr.value=''[]'' then
          raise debug ''Must NOT Exist'';
	      if label_exist_flag then
              res := res and false;
	      else
	          res := res and true;
	      end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if label_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
	    elsif defined(Resource.annotations,label_) then
	       -- check if all any values from the array fit the attr.value
	       pg_match_value := ''{"value":''||attr_value ||''}'';
	       -- $.<label_name>? (@ == $value)
	       pg_path := ''$.''||label_||'' ? (@ == $value)'';
	       raise debug ''pg_path label = : %'',pg_path;
	--  BROKEN CODE:
	--       if jsonb_path_exists(hstore_to_jsonb (Resource.labels),pg_path::jsonpath,pg_match_value::jsonb) then
	--          res := res and true;
	--       else
	--          res := res and false;
	--       end if;
	-- TEMP WORKAROUND:
	        hs_label_value := Resource.annotations -> label_;
            if hs_label_value = attr_value then
               res := res and true;
            else
               res := res and false;
	        end if;
	-- END WORKAROUND
	    else
	       res := res and false;
        end if;
        continue;

      -- spec
      elsif attr.key ~ ''^\/spec'' then
         raise debug ''ATTRIBUTE = : %'',''SPEC'';
  	     pg_path := ''$''||replace(replace(attr.key,''/spec'',''''),''/'',''.'');
  	     attribute_exist_flag := jsonb_path_exists(Resource.spec,pg_path::jsonpath);
         raise debug ''attribute_exist_flag = : %'',attribute_exist_flag;
         raise debug ''pg_path = : %'',pg_path;
         if attr.value=''[]'' then
            raise debug ''Must NOT Exist'';
	        if attribute_exist_flag then
               res := res and false;
	       else
	           res := res and true;
	       end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if attribute_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
  	    elsif attribute_exist_flag and attr_value is not null then
  	       pg_match_value := ''{"value":''||attr_value ||''}'';
  	       raise debug ''pg_match_value =  : %'',pg_match_value;
  	       pg_path := pg_path||'' ? (@ == $value)'';
  	       raise debug ''pg_path = : %'',pg_path;
  	       if jsonb_path_exists(Resource.spec,pg_path::jsonpath,pg_match_value::jsonb) then
  	          res := res and true;
  	       else
  	          res := res and false;
  	       end if;
	    else
	       res := res and false;
	    end if;
	    continue;

      -- spec
      elsif attr.key ~ ''^\/status'' then
         raise debug ''ATTRIBUTE = : %'',''STATUS'';
  	     pg_path := ''$''||replace(replace(attr.key,''/status'',''''),''/'',''.'');
  	     attribute_exist_flag := jsonb_path_exists(Resource.status,pg_path::jsonpath);
         raise debug ''attribute_exist_flag = : %'',attribute_exist_flag;
         raise debug ''pg_path = : %'',pg_path;
         if attr.value=''[]'' then
            raise debug ''Must NOT Exist'';
	        if attribute_exist_flag then
               res := res and false;
	       else
	           res := res and true;
	       end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if attribute_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
  	    elsif attribute_exist_flag and attr_value is not null then
  	       pg_match_value := ''{"value":''||attr_value ||''}'';
  	       raise debug ''pg_match_value =  : %'',pg_match_value;
  	       pg_path := pg_path||'' ? (@ == $value)'';
  	       raise debug ''pg_path = : %'',pg_path;
  	       if jsonb_path_exists(Resource.status,pg_path::jsonpath,pg_match_value::jsonb) then
  	          res := res and true;
  	       else
  	          res := res and false;
  	       end if;
	    else
	       res := res and false;
	    end if;
	    continue;

      -- kind
      elsif attr.key ~ ''^\/kind'' then
         raise debug ''attr.value = : %'',attr.value;
         raise debug ''aResource.kind= : %'',json_build_array(Resource.kind)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.kind)::jsonb then
            res := res and true;
         else
  	        res := res and false;
         end if;
         continue;

      -- resource id
      elsif attr.key ~ ''^\/metadata\/id'' then
         raise debug ''attr.value = : %'',attr.value;
  	     raise debug ''aResource.kind= : %'',json_build_array(Resource.resource_id)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.resource_id)::jsonb then
  	        res := res and true;
  	     else
  	        res := res and false;
  	     end if;
  	     continue;

      -- namespace
      elsif attr.key ~ ''^\/metadata\/namespace'' then
         raise debug ''attr.value = : %'',attr.value;
         raise debug ''aResource.namespace= : %'',json_build_array(Resource.namespace)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.namespace)::jsonb then
  	        res := res and true;
  	     else
  	        res := res and false;
  	     end if;
  	     continue;

      -- name
      elsif attr.key ~ ''^\/metadata\/name'' then
         raise debug ''attr.value = : %'',attr.value;
         raise debug ''aResource.name= : %'',json_build_array(Resource.name)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.name)::jsonb then
  	        res := res and true;
  	     else
  	        res := res and false;
  	     end if;
  	     continue;

      -- version
      elsif attr.key ~ ''^\/metadata\/version'' then
         raise debug ''attr.value = : %'',attr.value;
         raise debug ''aResource.version= : %'',json_build_array(Resource.version)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.version)::jsonb then
  	        res := res and true;
  	     else
  	        res := res and false;
  	     end if;
  	     continue;

      -- uuid
      elsif  attr.key ~ ''^\/metadata\/uuid''  then
         raise debug ''attr.value = : %'',attr.uuid;
         raise debug ''aResource.version= : %'',json_build_array(Resource.uuid)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.uuid)::jsonb then
  	        res := res and true;
  	     else
  	        res := res and false;
  	     end if;
  	     continue;

      -- created by
      elsif attr.key ~ ''^\/metadata\/createdBy'' then
         raise debug ''attr.value = : %'',attr.uuid;
         raise debug ''aResource.createdby = : %'',json_build_array(Resource.created_by)::jsonb;
         if attr.value=''[]'' then
            res := res and false;
         elsif attr.value is null then
  	        res := res and true;
         elsif attr.value::jsonb @> json_build_array(Resource.created_by)::jsonb then
  	        res := res and true;
  	     else
  	        res := res and false;
  	     end if;
  	     continue;

      -- last updated by (may not exist)
      elsif attr.key ~ ''^\/metadata\/lastUpdatedBy'' then
         raise debug ''ATTRIBUTE = : %'',''lastUpdatedBy'';
   	     pg_path := ''$''||replace(replace(attr.key,''/lastUpdatedBy'',''''),''/'',''.'');
   	     attribute_exist_flag := jsonb_path_exists(Resource.updated_by,pg_path::jsonpath);
         raise debug ''attribute_exist_flag = : %'',attribute_exist_flag;
         raise debug ''pg_path = : %'',pg_path;
         if attr.value=''[]'' then
            raise debug ''Must NOT Exist'';
	        if attribute_exist_flag then
               res := res and false;
	       else
	           res := res and true;
	       end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if attribute_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
  	    elsif attribute_exist_flag and attr_value is not null then
  	       pg_match_value := ''{"value":''||attr_value ||''}'';
  	       raise debug ''pg_match_value =  : %'',pg_match_value;
  	       pg_path := pg_path||'' ? (@ == $value)'';
  	       raise debug ''pg_path = : %'',pg_path;
  	       if jsonb_path_exists(Resource.updated_by,pg_path::jsonpath,pg_match_value::jsonb) then
  	          res := res and true;
  	       else
  	          res := res and false;
  	       end if;
	    else
	       res := res and false;
	    end if;
	    continue;

      -- parent (may not exist)
      elsif attr.key ~ ''^\/metadata\/parent'' then
         raise debug ''ATTRIBUTE = : %'',''parent'';
   	     pg_path := ''$''||replace(replace(attr.key,''/parent'',''''),''/'',''.'');
   	     attribute_exist_flag := jsonb_path_exists(Resource.parent_resource_id,pg_path::jsonpath);
         raise debug ''attribute_exist_flag = : %'',attribute_exist_flag;
         raise debug ''pg_path = : %'',pg_path;
         if attr.value=''[]'' then
            raise debug ''Must NOT Exist'';
	        if attribute_exist_flag then
               res := res and false;
	       else
	           res := res and true;
	       end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if attribute_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
  	    elsif attribute_exist_flag and attr_value is not null then
  	       pg_match_value := ''{"value":''||attr_value ||''}'';
  	       raise debug ''pg_match_value =  : %'',pg_match_value;
  	       pg_path := pg_path||'' ? (@ == $value)'';
  	       raise debug ''pg_path = : %'',pg_path;
  	       if jsonb_path_exists(Resource.parent_resource_id,pg_path::jsonpath,pg_match_value::jsonb) then
  	          res := res and true;
  	       else
  	          res := res and false;
  	       end if;
	    else
	       res := res and false;
	    end if;
	    continue;

      -- username (may not exist on older data)
      elsif attr.key ~ ''^\/status\/pendingAction\/username'' then
         raise debug ''ATTRIBUTE = : %'',''username'';
   	     pg_path := ''$''||replace(replace(attr.key,''/status/pendingAction/username'',''/pendingAction/username''),''/'',''.'');
   	     attribute_exist_flag := jsonb_path_exists(Resource.lifecycle_requested_by,pg_path::jsonpath);
         raise debug ''attribute_exist_flag = : %'',attribute_exist_flag;
         raise debug ''pg_path = : %'',pg_path;
         if attr.value=''[]'' then
            raise debug ''Must NOT Exist'';
	        if attribute_exist_flag then
               res := res and false;
	       else
	           res := res and true;
	       end if;
	    elsif attr.value is null then
	       raise debug ''Must Exist'';
	       if attribute_exist_flag then
	          res := res and true;
	       else
	          res := res and false;
	       end if;
  	    elsif attribute_exist_flag and attr_value is not null then
  	       pg_match_value := ''{"value":''||attr_value ||''}'';
  	       raise debug ''pg_match_value =  : %'',pg_match_value;
  	       pg_path := pg_path||'' ? (@ == $value)'';
  	       raise debug ''pg_path = : %'',pg_path;
  	       if jsonb_path_exists(Resource.lifecycle_requested_by,pg_path::jsonpath,pg_match_value::jsonb) then
  	          res := res and true;
  	       else
  	          res := res and false;
  	       end if;
	    else
	       res := res and false;
	    end if;
	    continue;

      end if;
    end loop;
    return res;
  END;
'
LANGUAGE 'plpgsql';

-- core procedures
DROP TYPE IF EXISTS core.QuotaType CASCADE;
CREATE TYPE core.QuotaType AS (
        uuid varchar,
        namespace varchar,
        name varchar,
        scope smallint,
        type varchar,
        aggregation varchar,
        constraints jsonb,
        message varchar,
        value_attribute_path varchar,
        value_number_default integer,
        comparison_attribute_path varchar,
        filter_kinds varchar[],
        filter_names varchar[],
        filter_attributes jsonb,
        block_actions varchar[],
        scoped_namespace varchar
);

DROP TYPE IF EXISTS core.QuotaResponseType CASCADE;
CREATE TYPE core.QuotaResponseType AS (
        allowed boolean,
        resource_id varchar,
        name varchar,
        message varchar,
        currentvalue integer,
        limitvalue integer,
        blocked boolean
);

CREATE OR REPLACE FUNCTION core.quota_check_response (Result core.QuotaResponseType) RETURNS jsonb AS
'
BEGIN
        return jsonb_build_object(''allowed'', Result.allowed, ''failure'',
                jsonb_build_object(''quotaId'', Result.resource_id,
                        ''quotaName'', Result.name,
                        ''message'', Result.message,
                        ''current'', Result.currentvalue,
                        ''limit'', Result.limitvalue,
                        ''actionBlocked'', Result.blocked)
        );
END;
'
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION core.quota_count (Resource rbac.ResourceType, Quota core.QuotaType)
        RETURNS jsonb
AS
'
DECLARE
        attr record;
        attr_key varchar;
        attr_value varchar;
        group_by varchar;
        resource_value varchar;
        res boolean;
        current integer;
        quota_limit integer;
        quota_resource_id varchar;
        Result core.QuotaResponseType;
BEGIN
    group_by = '''';
    Result = (true, null, null, null, null, null, false)::core.QuotaResponseType;
    -- First determining if this quota groups by anything by looping through attributes
        -- this generates a string of ands to append to the end of the query in the resources temporary table
        -- for example, if filtering by kind, we will only want to get a count of resources that have the same kind as the resource being created/updated
                -- thus, we will add " and r.kind = ''our-resource''s-kind''" to our filtering
    for attr in (select ( jsonb_each_text(Quota.filter_attributes)).*  )
    loop
        attr_key = attr.key;
        attr_value = attr.value;
        -- if current attribute value is ''='' we want to group by this
        if attr_value = ''='' then
                resource_value = null;
                if attr_key = ''/kind'' then
                        group_by = group_by || '' and r.kind = '''''' || Resource.kind || '''''''';
                elsif attr_key ~ ''^\/spec'' then
                        attr_key = substring(attr_key from 7);
                        EXECUTE (''select $1 -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''''') into resource_value using Resource.spec;
                        -- if our resource does not have the attribute of interest for grouping, we can simply return true
                        if resource_value is null then
                                return (select * from core.quota_check_response(Result));
                        end if;
                        group_by = group_by || '' and r.spec -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''' = '''''' || resource_value || '''''''' ;
                elsif attr_key ~ ''^\/status'' then
                        attr_key = substring(attr_key from 9);
                        EXECUTE (''select $1 -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''''') into resource_value using Resource.status;
                        -- if our resource does not have the attribute of interest for grouping, we can simply return true
                        if resource_value is null then
                                return (select * from core.quota_check_response(Result));
                        end if;
                        group_by = group_by || '' and r.status -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''' = '''''' || resource_value || '''''''' ;
                elsif attr_key ~ ''^\/metadata\/namespace'' then
                        group_by = group_by || '' and r.namespace = '''''' || Resource.namespace || '''''''';
                elsif attr_key ~ ''^\/metadata\/name'' then
                        group_by = group_by || '' and r.name = '''''' || Resource.name || '''''''';
                elsif attr_key ~ ''^\/metadata\/createdby'' then
                        group_by = group_by || '' and r.created_by = '''''' || Resource.created_by || '''''''';
                elsif attr_key ~ ''^\/metadata\/updatedby'' then
                        group_by = group_by || '' and r.updated_by = '''''' || Resource.updated_by || '''''''';
                elsif attr_key ~ ''^\/metadata\/labels'' then
                        attr_key = substring(attr_key from 18);
                        EXECUTE (''select $1 -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''''') into resource_value using Resource.labels;
                        -- if our resource does not have the attribute of interest for grouping, we can simply return true
                        if resource_value is null then
                                return (select * from core.quota_check_response(Result));
                        end if;
                        group_by = group_by || '' and r.labels -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''' = '''''' || resource_value || '''''''' ;
                elsif attr_key ~ ''^\/metadata\/annotations'' then
                        attr_key = substring(attr_key from 23);
                        EXECUTE (''select $1 -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''''') into resource_value using Resource.annotations;
                        -- if our resource does not have the attribute of interest for grouping, we can simply return true
                        if resource_value is null then
                                return (select * from core.quota_check_response(Result));
                        end if;
                        group_by = group_by || '' and r.annotations -> '''''' || replace(attr_key, ''/'', '''''' -> '''''') || '''''' = '''''' || resource_value || '''''''' ;
                else
                        -- if wanting to filter by an unsupported attribute, then return true
                        return (select * from core.quota_check_response(Result));
                end if;
        end if;
    end loop;

    quota_limit := cast (Quota.constraints ->> ''maximum'' as int);
    -- If we are grouping by an attribute, then we need to build our query dynamically
    -- For comments about this query, look at the else statement below (query is the same, minus the filtering we are doing for grouping by)
    if group_by != '''' then
        EXECUTE (''with physical_namespaces as (
                        select namespace from rbac.rbac_namespaces_path
                        where $1 = any(namespace_array)
                ), logical_namespaces as (
                        select distinct rnp.namespace from physical_namespaces p
                        inner join core.resource_group rg on rg.chargeback_group = p.namespace
                        inner join rbac.rbac_namespaces_path rnp on rg.name = any(rnp.namespace_array)
                ), all_namespaces as (
                        select namespace from logical_namespaces
                        union
                        select namespace from physical_namespaces
                ), resources as (
                        select r.resource_id, max(h.offset_value) as max_offset from core.resource r
                                inner join all_namespaces a on r.namespace = a.namespace
                                inner join core.history h on r.uuid = h.uuid and h.history is true and h.ready is true and h.active is true and h.removed is false
                                where ($2 is null
                                        or r.kind = any($2)
                                        or ''''*'''' = any($2))
                                and ($3 is null
                                        or r.name = any($3)
                                        or ''''*'''' = any($3))
                                and ($4 is null or
                                rbac.abac_check((r.resource_id, r.namespace, r.kind, r.name, r.version, r.uuid, r.event_id, r.created, r.created_by, r.updated, r.updated_by, r.deleted, r.deleted_by,
                                        r.annotations, r.labels, r.parent_resource_id, r.spec, r.status, r.lifecycle_action, r.lifecycle_requested_by, r.lifecycle_request_source, r.lifecycle_started,
                                        r.lifecycle_completed, r.lifecycle_uuid, r.lifecycle_context, r.agents_status, r.ready, r.pending, r.metrics, r.parent_seq, r.offset_value), $4))
                                and r.kind not in (''''policy'''', ''''kind'''', ''''agent'''', ''''namespace'''',
                                        ''''role'''', ''''service-account'''', ''''secret'''', ''''group'''',
                                        ''''example.namespace-users.v1'''', ''''example.namespace-apps.v1'''',
                                        ''''example.rg-standard.v1'''', ''''example.rg-app.v1'''',''''quota'''')
                                and r.resource_id != $5'' || group_by ||
                 '' group by r.resource_id) select count(resource_id) from resources r '')
                 into current using Quota.scoped_namespace, Quota.filter_kinds, Quota.filter_names, Quota.filter_attributes, Resource.resource_id;
    else
        current := (-- selecting namespaces physically under scoped_namespace determined by quota
                with physical_namespaces as (
                        select namespace from rbac.rbac_namespaces_path
                        where Quota.scoped_namespace = any(namespace_array)
                ),
                -- finding all namespaces that logically should be included in count based on physical namespaces
                logical_namespaces as (
                        select distinct rnp.namespace from physical_namespaces p
                        inner join core.resource_group rg on rg.chargeback_group = p.namespace
                        inner join rbac.rbac_namespaces_path rnp on rg.name = any(rnp.namespace_array)
                ),
                -- combine physical and logical namespaces into one table
                all_namespaces as (
                        select namespace from logical_namespaces
                        union
                        select namespace from physical_namespaces
                ),
                -- find the existing count of resources based on quota filters and namespaces found above
                resources as (
                        select r.resource_id, max(h.offset_value) as max_offset from core.resource r
                                inner join all_namespaces a on r.namespace = a.namespace -- only count resources in namespaces found above
                                inner join core.history h on r.uuid = h.uuid and h.history is true and h.ready is true and h.active is true and h.removed is false
                                -- filter for kind based on quota
                                where (Quota.filter_kinds is null
                                        or r.kind = any(Quota.filter_kinds)
                                        or ''*'' = any(Quota.filter_kinds))
                                -- filter for name based on quota
                                and (Quota.filter_names is null
                                        or r.name = any(Quota.filter_names)
                                        or ''*'' = any(Quota.filter_names))
                                -- filter for attributes based on quota
                                and (Quota.filter_attributes is null or
                                        -- reusing abac check as an attribute filter here
                                        rbac.abac_check((r.resource_id, r.namespace, r.kind, r.name, r.version, r.uuid, r.event_id, r.created, r.created_by, r.updated, r.updated_by, r.deleted, r.deleted_by,
                                        r.annotations, r.labels, r.parent_resource_id, r.spec, r.status, r.lifecycle_action, r.lifecycle_requested_by, r.lifecycle_request_source, r.lifecycle_started,
                                        r.lifecycle_completed, r.lifecycle_uuid, r.lifecycle_context, r.agents_status, r.ready, r.pending, r.metrics, r.parent_seq, r.offset_value), Quota.filter_attributes))
                                -- filter out system kinds
                                and r.kind not in (''policy'', ''kind'', ''agent'', ''namespace'',
                                        ''role'', ''service-account'', ''secret'', ''group'',
                                        ''example.namespace-users.v1'', ''example.namespace-apps.v1'',
                                        ''example.rg-standard.v1'', ''example.rg-app.v1'',''quota'')
                                -- filter in case of update
                                and r.resource_id != Resource.resource_id
                                group by r.resource_id
                )
                -- return existing count of resources
                select count(resource_id) from resources r);
    end if;
    -- set res to false if the existing count of resources is equal to or greater than the imposed quota limit, true otherwise
    -- when true, the resource can be created or updated
    res := not (current >= quota_limit);
    if res = false then
        quota_resource_id := (select resource_id from core.resource where uuid = Quota.uuid);
        Result := (res, quota_resource_id, Quota.name, Quota.message, current, quota_limit, false)::core.QuotaResponseType;
        return (select * from core.quota_check_response(Result));
    end if;
    Result := (res, null, null, null, null, null, false);
    return (select * from core.quota_check_response(Result));
END;
'
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION core.quota_check (action varchar, Resource rbac.ResourceType)
        RETURNS jsonb
AS
'
DECLARE
        res boolean;
        quota_row record;
        json_response jsonb;
        quota_resource_id varchar;
BEGIN
        res := true;
        IF substring(lower(action), 1, 6) not in (''create'', ''update'') THEN
                return core.quota_check_response((true, null, null, null, null, null, false));
        END IF;
        FOR quota_row IN
        -- First find all applicable quotas for this particular resource (parameter) and intended action (parameter), taking into account
        -- a. the quota filters -- does this apply to our resource?
        -- b. the LOGICAL hierarchy which includes application resource group as the highest resource group ancestor
        (
                -- Getting the physical lineage of the resource
                with lineage as (
                        select a.namespace, a.rank * 2 as rank
                        from rbac.rbac_namespaces_path np
                        left join lateral unnest(np.namespace_array) with ordinality a(namespace, rank) on true
                        where np.namespace = Resource.namespace
                ),
                -- If there are resource groups in the physical lineage of the resource, get the application chargeback group for the resource
                apprg as (
                        select namespace, rank from (
                                select g.chargeback_group as namespace, l.rank - 1 as rank, g.type from core.resource_group g
                                inner join lineage l on l.namespace = g.name
                                -- get chargeback groups that are Application resource groups and don''t already exist in the lineage of the resource
                                inner join core.resource_group rg on g.chargeback_group = rg.name and rg.type = ''APP'' and rg.name not in (select namespace from lineage)
                        ) cg order by rank limit 1
                ),
                -- Get logical lineage of resource
                combined as (
                        select namespace from (
                                select namespace, rank from lineage
                                union
                                select namespace, rank from apprg
                        ) ns order by rank
                ),
                -- Get logical lineage of resource with rank (used for quota scope purposes)
                namespaces as (
                        select namespace, row_number() over () rank from combined
                )
                -- Selecting quota in within logical lineage of resource whose filters apply to resource
                select uuid, q.namespace, name, scope, type, aggregation, constraints, message, value_attribute_path, value_number_default, comparison_attribute_path,
                        filter_kinds, filter_names, filter_attributes, block_actions, n1.namespace as scoped_namespace
                        from core.quota q
                        inner join namespaces n on q.namespace = n.namespace
                        inner join namespaces n1 on n1.rank = n.rank + q.scope --based on scope, does quota apply to this resource?
                        where not (action = any(allow_actions)) or allow_actions is null -- does allow_actions allow this action?
                        and (filter_kinds is null or Resource.kind = any(filter_kinds) or ''*'' = any(filter_kinds)) -- does quota apply to resource''s kind?
                        and (filter_names is null or Resource.name = any(filter_names) or ''*'' = any(filter_names)) -- does quota apply to resource''s name?
                        -- does quota apply to resource''s attributes?
                        -- reusing abac check as an attribute filter here, not actually checking abac
                        and (filter_attributes is null or rbac.abac_check((Resource.resource_id,
                                Resource.namespace,
                                Resource.kind,
                                Resource.name,
                                Resource.version,
                                Resource.uuid,
                                Resource.event_id,
                                Resource.created,
                                Resource.created_by,
                                Resource.updated,
                                Resource.updated_by,
                                Resource.deleted,
                                Resource.deleted_by,
                                Resource.annotations,
                                Resource.labels,
                                Resource.parent_resource_id,
                                Resource.spec,
                                Resource.status,
                                Resource.lifecycle_action,
                                Resource.lifecycle_requested_by,
                                Resource.lifecycle_request_source,
                                Resource.lifecycle_started,
                                Resource.lifecycle_completed,
                                Resource.lifecycle_uuid,
                                Resource.lifecycle_context,
                                Resource.agents_status,
                                Resource.ready,
                                Resource.pending,
                                Resource.metrics,
                                Resource.parent_seq,
                                Resource.offset_value), filter_attributes))
        )
        LOOP
                -- Check to make sure each quota is currently supported by example

                -- Raise notice for subscription, which is unsupported
                IF quota_row.type = ''subscription'' THEN
                        RAISE NOTICE ''Quota: % has type = subscription, which is currently unsupported by example. Contact the example team if you have any questions!'', quota_row.name;
                        CONTINUE;
                END IF;

                -- Raise notice for quota with aggregation = sum or maximum, which is unsupported
                IF quota_row.aggregation != ''count'' THEN
                        RAISE NOTICE ''Quota: % has an aggregation other than count, which is currently unsupported by example. Contact the example team if you have any questions!'', quota_row.name;
                        CONTINUE;
                END IF;

                -- Raise notice for quota with negative scope, which is unsupported
                IF quota_row.scope < 0 THEN
                        RAISE NOTICE ''Quota: % has a scope that is negative, which is currently unsupported by example. Contact the example team if you have any questions!'', quota_row.name;
                        CONTINUE;
                END IF;

                -- Raise notice for quota with value_attribute_path, which is unsupported
                IF quota_row.value_attribute_path is not null THEN
                        RAISE NOTICE ''Quota: % has a value attribute path, which is currently unsupported by example. Contact the example team if you have any questions!'', quota_row.name;
                        CONTINUE;
                END IF;

                -- Raise notice for quota with value_number_default, which is unsupported
                IF quota_row.value_number_default is not null THEN
                        RAISE NOTICE ''Quota: % has a default value, which is currently unsupported by example. Contact the example team if you have any questions!'', quota_row.name;
                END IF;

                -- Raise notice for quota with comparison_attribute_path, which is unsupported
                IF quota_row.comparison_attribute_path is not null THEN
                        RAISE NOTICE ''Quota: % has a comparison value, which is currently unsupported by example. Contact the example team if you have any questions!'', quota_row.name;
                END IF;

                IF quota_row.block_actions is not null and action = any(quota_row.block_actions) THEN
                        res := false;
                        quota_resource_id := (select resource_id from core.resource where uuid = quota_row.uuid);
                        json_response := (select * from core.quota_check_response((false, quota_resource_id, quota_row.name, quota_row.message, null, null, true)));
                        EXIT;
                END IF;

                -- Loop through all quotas found by the above query, and check if resource could be created/updated based on each quota
                IF quota_row.aggregation = ''count'' THEN
                        json_response := core.quota_count(Resource, (quota_row.uuid, quota_row.namespace, quota_row.name, quota_row.scope,
                                quota_row.type, quota_row.aggregation, quota_row.constraints, quota_row.message, quota_row.value_attribute_path,
                                quota_row.value_number_default, quota_row.comparison_attribute_path, quota_row.filter_kinds, quota_row.filter_names,
                                quota_row.filter_attributes, quota_row.block_actions, quota_row.scoped_namespace));
                        res := cast (json_response -> ''allowed'' as boolean);
                END IF;
                -- if false, exit loop
                IF res = false THEN
                        EXIT;
                END IF;
        END LOOP;
        return json_response;
END;
'
LANGUAGE 'plpgsql';