set ver off pages 50000 lines 260 tab off echo off
undef snap_id_from
undef snap_id_to
undef sort_col_nr
undef top_n
undef phv
def snap_id_from="&1"
def snap_id_to="&2"
def sort_col_nr="&3"
def top_n="&4"
def phv="&5"
col inst for 9999
col time for a19
col force_matching_signature for 99999999999999999999
col executions for 9999999999
col rows_processed for 99999999999
col elapsed_time_s for 9999999.999
col cpu_time_s for 9999999.999
col iowait_s for 9999999.999
col clwait_s for 9999999.999
col apwait_s for 9999999.999
col ccwait_s for 9999999.999
col buffer_gets for 9999999999999999
col disk_reads for 9999999999999999
col direct_writes for 9999999999999999
col diff_sqlid for a13
col diff_plan for a10
col diff_fms for a20


BREAK ON inst SKIP 1

select * from (
select to_char(plan_hash_value) diff_plan,
    sql_id diff_sqlid,
    to_char(force_matching_signature) diff_fms,
    sum(hss.executions_delta) executions,
    round(sum(hss.elapsed_time_delta)/1000000,3) elapsed_time_s,
    round(sum(hss.cpu_time_delta)/1000000,3) cpu_time_s,
    round(sum(hss.iowait_delta)/1000000,3) iowait_s,
    round(sum(hss.clwait_delta)/1000000,3) clwait_s,
    round(sum(hss.apwait_delta)/1000000,3) apwait_s,
    round(sum(hss.ccwait_delta)/1000000,3) ccwait_s,
    round(sum(hss.rows_processed_delta),3) rows_processed,
    round(sum(hss.buffer_gets_delta),3) buffer_gets,
    round(sum(hss.disk_reads_delta),3) disk_reads,
    round(sum(hss.direct_writes_delta),3) direct_writes
from dba_hist_sqlstat hss, dba_hist_snapshot hs
where hss.snap_id=hs.snap_id
    and plan_hash_value=&phv
    and hs.snap_id between &snap_id_from and &snap_id_to
group by plan_hash_value, sql_id, force_matching_signature
order by &sort_col_nr desc)
where rownum<=&top_n;
