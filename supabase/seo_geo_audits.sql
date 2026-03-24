create table if not exists public.seo_geo_audits (
    audit_id text primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    status text not null,
    intake jsonb not null default '{}'::jsonb,
    selected_skills jsonb not null default '[]'::jsonb,
    selected_frameworks jsonb not null default '[]'::jsonb,
    tool_results jsonb not null default '{}'::jsonb,
    markdown_path text not null default '',
    markdown_content text not null default '',
    export jsonb not null default '{}'::jsonb,
    error text not null default '',
    progress jsonb not null default '[]'::jsonb
);

create index if not exists seo_geo_audits_status_idx on public.seo_geo_audits (status);
create index if not exists seo_geo_audits_updated_at_idx on public.seo_geo_audits (updated_at desc);

alter table public.seo_geo_audits enable row level security;

comment on table public.seo_geo_audits is
'Stores SEO/GEO webapp audit runs. Intended for server-side writes through the service role key.';
