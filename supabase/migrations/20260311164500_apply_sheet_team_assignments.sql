DO $$
BEGIN
  IF EXISTS (
    WITH required_users(user_id, expected_display_name) AS (
      VALUES
    ('1579089b-b98d-4725-8703-261b43b9fd9a'::uuid, 'Wannes'),
    ('9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'Nick'),
    ('e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'Stephen'),
    ('069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'Bjorn'),
    ('f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'Diego'),
    ('8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'Dries'),
    ('22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'Thibo')
    )
    SELECT 1
    FROM required_users ru
    LEFT JOIN public.profiles p ON p.user_id = ru.user_id
    WHERE p.user_id IS NULL
       OR lower(trim(COALESCE(p.display_name, ''))) <> lower(trim(ru.expected_display_name))
  ) THEN
    RAISE EXCEPTION 'Sheet team-owners konden niet bevestigd worden in profiles';
  END IF;
END;
$$;
create temporary table tmp_sheet_team_assignments (
  client_id uuid not null,
  user_id uuid not null,
  assignment_role public.app_role not null,
  is_primary boolean not null
) on commit drop;
insert into tmp_sheet_team_assignments (client_id, user_id, assignment_role, is_primary)
values
  ('8817a8aa-e1ac-4fe6-9cac-62937031472f'::uuid, '1579089b-b98d-4725-8703-261b43b9fd9a'::uuid, 'account_manager'::public.app_role, true),
  ('8e78bf50-05c3-4f34-abf2-eb99a7696bdc'::uuid, '1579089b-b98d-4725-8703-261b43b9fd9a'::uuid, 'account_manager'::public.app_role, true),
  ('98c541e9-14b5-4f0d-b4f4-b9dc0d82ce1b'::uuid, '1579089b-b98d-4725-8703-261b43b9fd9a'::uuid, 'account_manager'::public.app_role, true),
  ('cca64c7f-fce9-40df-9f16-127dfaaedf91'::uuid, '1579089b-b98d-4725-8703-261b43b9fd9a'::uuid, 'account_manager'::public.app_role, true),
  ('ffe7e069-eca9-4c13-8d60-279f68aaa036'::uuid, '1579089b-b98d-4725-8703-261b43b9fd9a'::uuid, 'account_manager'::public.app_role, true),
  ('21e75ef5-047a-44e0-b34e-b112b9cd6cad'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('26f8db91-cc84-4bba-991d-30b01a09751f'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('3e3bdb1c-1be1-4adf-8177-423a75a5d247'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('4f91594d-4cb5-4ed5-8477-90266137d2f3'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('61ed2145-bae5-4fd8-9fad-b340854c2271'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('6c433a42-75d8-468c-9b0f-3923bf8dc0b4'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('743f2ff2-b614-43b1-997d-d1fec706c568'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('7d999865-9069-4284-b895-dff1e44f7e45'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('8650a302-7901-4b54-99a9-c763630005c7'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('91bb4943-d909-4b51-b416-d42cd802b8e5'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('962b878e-f4b2-41da-8394-5998ce532ace'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('97e9b1e3-360b-4b0c-bfae-d260ef1befb5'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('b9e61312-97de-4295-b2fc-acdb3387d273'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('c0457574-d352-4ca5-bafb-7e01f44aa754'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('c334fb33-b8df-448b-8e18-84f38f737569'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('cba9c982-075e-4460-a882-7318c18e1f19'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('d0452bfa-68c7-40a4-befa-9796ce8007ee'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('dbb199e9-8078-4256-b58c-a6ae24ddcbdb'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('de4745ff-c618-4d7a-9022-3b4c8cbecff9'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('f9bc06b4-04c8-4a5a-ad3a-1b61f4f3a19d'::uuid, '9a2b57ba-8b59-452a-a28c-f85be384f3dd'::uuid, 'account_manager'::public.app_role, true),
  ('0543abf0-0633-484e-b52c-e2ee873ad36d'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('0efeff50-f3b8-4a5a-bd8c-3bcc0945f5b3'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('12191f72-feb5-4fd0-86b6-220bdc421f54'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('1622df4d-9ba6-4b64-aac6-12246a3e0d2e'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('270d56d4-9a0c-4592-a338-786b913ec739'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('2b37026f-a070-4aa5-995b-3e93cd8b5c44'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('36c1cc65-bed8-46db-a3ce-28584c2d3cfa'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('36cee5a3-ae53-476b-8488-1a524af15d8b'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('3f83c9a2-d57b-423b-9656-549d9ebb9959'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('41577c97-d47b-40f8-86f0-74555cbf95e0'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('448f2b2e-ba98-48af-bee6-df3ec4a839b1'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('45f51f3f-acad-41d7-8f4b-c923ae1e3e96'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('46c72c8e-5da5-4ea8-be8a-6e75639ae713'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('4e57a8d6-e4f2-4b7f-8697-9ff4a553f9b9'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('5906c954-e717-4eb7-b479-2f7c9d659b64'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('645dc01b-106c-4db7-b8f2-1228a4612dc3'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('646ec8c2-4920-416e-895b-248f9219af17'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('6e337920-f1fb-4e68-b49e-3a4a4cc678bb'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('6fc14b3c-a371-45b2-9daa-ebe28acd30bc'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('74b9a2b3-65d5-4600-98d7-c31549b9a716'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('8f12b69c-9c5b-43e9-a54f-05fd2ea4d9bd'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('91e9652d-e244-418a-b438-42f9f5620151'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('91ebf02b-04b1-4ec7-b256-e00ad41896c4'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('9a4a28a8-0cdd-4de8-b6dd-9cca7e360ead'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('a4197535-a35d-4b65-a1a6-a86e2501daf3'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('a72df588-bf6c-42aa-8106-eabf9531dd86'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('a8de290f-c0c9-497b-a975-f8620f9dd0a6'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('b85ff2a7-624c-42be-af46-ac7f5fb1f134'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('bb8e1115-bf60-4ee0-aa2c-c857668495ff'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('c4e52103-8098-44ce-9e5b-523ff4d7dfa0'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('c952917c-c441-45b5-985c-3f2b01f4f468'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('ce3931ca-3cc5-4357-bbbe-dbbc268e8e1a'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('d276d396-23d2-44e7-bd69-66c6ef679597'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('d7e0d1ec-a7db-40a7-a4cd-e92c219adacd'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('e2989739-498f-44b9-9fb7-18d80ee6cd6f'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('ed3a47c1-f98b-4f7a-9e79-7ed1f7896391'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('f0402ef6-235f-46d7-bb69-60ab58ff9577'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('f8472374-7027-4df4-b411-10f447675988'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('f8f800cb-ea40-4df0-9267-2e55f6614d37'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('fbe16ddd-a430-4b3b-8bd2-a2d9042b679c'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('fc4d15bf-2fa8-442d-9eca-ecee762a56d6'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('fd2f4d7b-b69e-4ab6-abd3-72cd7cdeda32'::uuid, 'e33ab752-b211-4619-8f5e-f5aa939a144a'::uuid, 'account_manager'::public.app_role, true),
  ('0e9ca0ba-6e7e-46d5-ab12-415d731d934c'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('3e3bdb1c-1be1-4adf-8177-423a75a5d247'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('743f2ff2-b614-43b1-997d-d1fec706c568'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('8817a8aa-e1ac-4fe6-9cac-62937031472f'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('91bb4943-d909-4b51-b416-d42cd802b8e5'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('98c541e9-14b5-4f0d-b4f4-b9dc0d82ce1b'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('a8de290f-c0c9-497b-a975-f8620f9dd0a6'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('cba9c982-075e-4460-a882-7318c18e1f19'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('cca64c7f-fce9-40df-9f16-127dfaaedf91'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('d0452bfa-68c7-40a4-befa-9796ce8007ee'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('d276d396-23d2-44e7-bd69-66c6ef679597'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('fbe16ddd-a430-4b3b-8bd2-a2d9042b679c'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('ffe7e069-eca9-4c13-8d60-279f68aaa036'::uuid, '069f098d-7b28-404d-8fb7-cfb597c11cab'::uuid, 'marketing'::public.app_role, false),
  ('029aa259-3c4b-4263-a491-60c878350ed4'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('12191f72-feb5-4fd0-86b6-220bdc421f54'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('1622df4d-9ba6-4b64-aac6-12246a3e0d2e'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('26f8db91-cc84-4bba-991d-30b01a09751f'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('46c72c8e-5da5-4ea8-be8a-6e75639ae713'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('4e57a8d6-e4f2-4b7f-8697-9ff4a553f9b9'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('74b9a2b3-65d5-4600-98d7-c31549b9a716'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('8e78bf50-05c3-4f34-abf2-eb99a7696bdc'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('8f12b69c-9c5b-43e9-a54f-05fd2ea4d9bd'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('91ebf02b-04b1-4ec7-b256-e00ad41896c4'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('a4197535-a35d-4b65-a1a6-a86e2501daf3'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('a72df588-bf6c-42aa-8106-eabf9531dd86'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('c4e52103-8098-44ce-9e5b-523ff4d7dfa0'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('d7e0d1ec-a7db-40a7-a4cd-e92c219adacd'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('e2989739-498f-44b9-9fb7-18d80ee6cd6f'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('f0402ef6-235f-46d7-bb69-60ab58ff9577'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('f1ef7824-382b-4503-8bb2-48fc3e0cad50'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('fc4d15bf-2fa8-442d-9eca-ecee762a56d6'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('fd2f4d7b-b69e-4ab6-abd3-72cd7cdeda32'::uuid, '22bcbc0e-cee8-4d1a-98fa-23f2b6872a72'::uuid, 'marketing'::public.app_role, false),
  ('0543abf0-0633-484e-b52c-e2ee873ad36d'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('0efeff50-f3b8-4a5a-bd8c-3bcc0945f5b3'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('18c57cb6-58dd-47dd-92eb-36941101a5a5'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('2b37026f-a070-4aa5-995b-3e93cd8b5c44'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('2d6f34ed-0d93-4c76-8ae5-5982d3a1b6a0'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('3d56de5f-8ea4-4138-9d05-fbedbdf62bdc'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('3f83c9a2-d57b-423b-9656-549d9ebb9959'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('41577c97-d47b-40f8-86f0-74555cbf95e0'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('45f51f3f-acad-41d7-8f4b-c923ae1e3e96'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('4f91594d-4cb5-4ed5-8477-90266137d2f3'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('6112656e-fcc6-4f28-b366-fdb97a88649a'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('61ed2145-bae5-4fd8-9fad-b340854c2271'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('6c433a42-75d8-468c-9b0f-3923bf8dc0b4'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('6e337920-f1fb-4e68-b49e-3a4a4cc678bb'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('6fc14b3c-a371-45b2-9daa-ebe28acd30bc'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('7d999865-9069-4284-b895-dff1e44f7e45'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('7da718ce-b67a-4c1a-a503-e5ecceddf303'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('862d54cf-3cab-4759-8783-900699f4c46f'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('8650a302-7901-4b54-99a9-c763630005c7'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('87c6a098-51a3-4ac8-a601-00bfd229feca'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('8a98a558-1fd6-44c6-87b9-b84ecbfb448f'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('91e9652d-e244-418a-b438-42f9f5620151'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('962b878e-f4b2-41da-8394-5998ce532ace'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('97e9b1e3-360b-4b0c-bfae-d260ef1befb5'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('9a4a28a8-0cdd-4de8-b6dd-9cca7e360ead'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('b85ff2a7-624c-42be-af46-ac7f5fb1f134'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('b9e61312-97de-4295-b2fc-acdb3387d273'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('bb8e1115-bf60-4ee0-aa2c-c857668495ff'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('c0457574-d352-4ca5-bafb-7e01f44aa754'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('c47e893d-1c9d-40b1-84fb-240f344e86e5'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('d276d396-23d2-44e7-bd69-66c6ef679597'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('de4745ff-c618-4d7a-9022-3b4c8cbecff9'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('ed3a47c1-f98b-4f7a-9e79-7ed1f7896391'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('f8472374-7027-4df4-b411-10f447675988'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('f9bc06b4-04c8-4a5a-ad3a-1b61f4f3a19d'::uuid, '8d58f59e-0c3a-434a-974c-1bdf05395783'::uuid, 'marketing'::public.app_role, false),
  ('21e75ef5-047a-44e0-b34e-b112b9cd6cad'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('270d56d4-9a0c-4592-a338-786b913ec739'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('30aec73e-3425-460c-b569-476b197cf117'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('645dc01b-106c-4db7-b8f2-1228a4612dc3'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('646ec8c2-4920-416e-895b-248f9219af17'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('967b4425-4f64-4893-8e70-a2f833a3af0a'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('c334fb33-b8df-448b-8e18-84f38f737569'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('c952917c-c441-45b5-985c-3f2b01f4f468'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('ce3931ca-3cc5-4357-bbbe-dbbc268e8e1a'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('dbb199e9-8078-4256-b58c-a6ae24ddcbdb'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false),
  ('f8f800cb-ea40-4df0-9267-2e55f6614d37'::uuid, 'f3bcc3a8-b97c-441c-b67c-f61762d24a45'::uuid, 'marketing'::public.app_role, false);
delete from public.client_team_members ctm
using (
  select distinct client_id, assignment_role
  from tmp_sheet_team_assignments
) targets
where ctm.client_id = targets.client_id
  and ctm.assignment_role = targets.assignment_role;
insert into public.client_team_members (
  client_id,
  user_id,
  assignment_role,
  is_primary,
  created_by
)
select
  client_id,
  user_id,
  assignment_role,
  is_primary,
  null
from tmp_sheet_team_assignments;
select public.sync_primary_account_manager_mirror(client_id)
from (
  select distinct client_id
  from tmp_sheet_team_assignments
  where assignment_role = 'account_manager'::public.app_role
) as account_manager_clients(client_id);
