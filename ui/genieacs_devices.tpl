{include file="sections/header.tpl"}

{if $hosts|@count == 0}
<div class="alert alert-warning">
    <i class="glyphicon glyphicon-warning-sign"></i>
    {Lang::T('No GenieACS hosts configured.')}
    <a href="{$_url}plugin/genieacs_config" class="alert-link">{Lang::T('Configure now')}</a>
</div>
{else}
<div class="row">
    <div class="col-md-12">
        <form class="form-inline pull-right" method="get" action="{$_url}plugin/genieacs_devices">
            <input type="hidden" name="_route" value="plugin/genieacs_devices">
            <div class="form-group">
                <select name="host_id" class="form-control" onchange="this.form.submit()">
                    <option value="">-- {Lang::T('Select Host')} --</option>
                    {foreach $hosts as $h}
                    <option value="{$h.id}" {if $activeHost && $activeHost.id==$h.id}selected{/if}>{$h.name|escape:'html'}</option>
                    {/foreach}
                </select>
            </div>
            <noscript><button type="submit" class="btn btn-default">{Lang::T('Go')}</button></noscript>
        </form>
        <a href="{$_url}plugin/genieacs_dashboard{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info pull-right">{Lang::T('Dashboard')}</a>
        <h3>{if $activeHost}{$activeHost.name|escape:'html'}{else}{Lang::T('GenieACS Devices')}{/if}</h3>
    </div>
</div>

{if $activeHost}
<div class="row">
    <div class="col-sm-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">
                <div class="pull-right">
                    <form class="form-inline" method="get" action="{$_url}plugin/genieacs_devices">
                        <input type="hidden" name="_route" value="plugin/genieacs_devices">
                        {if $activeHost}<input type="hidden" name="host_id" value="{$activeHost.id}">{/if}
                        <div class="input-group">
                            <input type="text" class="form-control input-sm" name="search" value="{$search}" placeholder="{Lang::T('Search serial, ID or PPP username...')}">
                            <span class="input-group-btn">
                                <button class="btn btn-success btn-sm" type="submit">{Lang::T('Search')}</button>
                                {if $search}
                                <a href="{$_url}plugin/genieacs_devices{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-default btn-sm">{Lang::T('Clear')}</a>
                                {/if}
                            </span>
                        </div>
                    </form>
                </div>
                {Lang::T('Devices')} ({$total})
            </div>
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped" id="deviceTable">
                        <thead>
                            <tr>
                                <th data-sort="int">#</th>
                                <th data-sort="string">{Lang::T('Serial Number')}</th>
                                <th data-sort="string">{Lang::T('PPP Username')}</th>
                                <th data-sort="string">{Lang::T('Fullname')}</th>
                                <th data-sort="string">{Lang::T('TR069 IP')}</th>
                                <th data-sort="float">{Lang::T('Temperature')}</th>
                                <th data-sort="float">{Lang::T('RX Power')}</th>
                                <th data-sort="int">{Lang::T('Status')}</th>
                                <th data-sort="int">{Lang::T('Connected')}</th>
                                <th data-sort="string">{Lang::T('Last Inform')}</th>
                                <th>{Lang::T('Manage')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $devices as $i => $d}
                            <tr>
                                <td>{$i+1+($page-1)*$limit}</td>
                                <td><a href="{$_url}plugin/genieacs_device&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}">{$d._deviceId._SerialNumber|default:$d._id|escape:'html'}</a></td>
                                <td>{$d._extracted.pppoe_username|escape:'html'}</td>
                                <td>{$d._extracted.fullname|escape:'html'}</td>
                                <td>{$d._extracted.tr069_ip|escape:'html'}</td>
                                <td>{if $d._extracted.temperature_raw !== null}{if $d._extracted.temperature_raw < 40}<span class="label label-success">{$d._extracted.temperature|escape:'html'}</span>{elseif $d._extracted.temperature_raw <= 50}<span class="label label-warning">{$d._extracted.temperature|escape:'html'}</span>{else}<span class="label label-danger">{$d._extracted.temperature|escape:'html'}</span>{/if}{else}{$d._extracted.temperature|escape:'html'}{/if}</td>
                                <td>{if $d._extracted.rx_power_raw !== null}{if $d._extracted.rx_power_raw <= -33.1}<span class="label label-default">{$d._extracted.rx_power|escape:'html'}</span>{elseif $d._extracted.rx_power_raw < -28}<span class="label label-danger">{$d._extracted.rx_power|escape:'html'}</span>{elseif $d._extracted.rx_power_raw <= -23}<span class="label label-warning">{$d._extracted.rx_power|escape:'html'}</span>{elseif $d._extracted.rx_power_raw <= -17}<span class="label label-success">{$d._extracted.rx_power|escape:'html'}</span>{else}<span class="label" style="background:#e91e63;color:#fff">{$d._extracted.rx_power|escape:'html'}</span>{/if}{else}{$d._extracted.rx_power|escape:'html'}{/if}</td>
                                <td data-sort-value="{if $d._lastInform && (time() - strtotime($d._lastInform)) < 300}1{else}0{/if}">
                                    {assign var="lastInform" value=$d._lastInform|default:''}
                                    {if $lastInform && (time() - strtotime($lastInform)) < 300}
                                        <span class="label label-success">{Lang::T('Online')}</span>
                                    {else}
                                        <span class="label label-danger">{Lang::T('Offline')}</span>
                                    {/if}
                                </td>
                                <td data-sort-value="{$d._extracted.connected_devices|default:0}">{$d._extracted.connected_devices|default:'-'}</td>
                                <td>{$d._lastInform|default:'-'|escape:'html'}</td>
                                <td>
                                    <a href="{$_url}plugin/genieacs_device&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info btn-xs">{Lang::T('Detail')}</a>
                                    <a href="{$_url}plugin/genieacs_reboot&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-warning btn-xs" onclick="return confirm('{Lang::T('Reboot this device?')}')">{Lang::T('Reboot')}</a>
                                    <a href="{$_url}plugin/genieacs_summon&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-success btn-xs" onclick="return confirm('{Lang::T('Summon this device?')}')">{Lang::T('Summon')}</a>
                                </td>
                            </tr>
                            {foreachelse}
                            <tr>
                                <td colspan="11" class="text-center">{Lang::T('No devices found')}</td>
                            </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
                {if $total > $limit}
                <div class="text-center">
                    <ul class="pagination">
                        {for $p=1 to ceil($total/$limit)}
                        <li{if $p==$page} class="active"{/if}>
                            <a href="{$_url}plugin/genieacs_devices&page={$p}{if $activeHost}&host_id={$activeHost.id}{/if}{if $search}&search={$search|escape:'url'}{/if}">{$p}</a>
                        </li>
                        {/for}
                    </ul>
                </div>
                {/if}
            </div>
        </div>
    </div>
</div>
{/if}
{/if}
{literal}<style>
#deviceTable th[data-sort]{cursor:pointer;white-space:nowrap;-webkit-user-select:none;user-select:none}
#deviceTable th[data-sort]::after{content:" \21C5";font-size:11px;margin-left:4px;opacity:.4}
#deviceTable th[data-sort].asc::after{content:" \25B2";opacity:1}
#deviceTable th[data-sort].desc::after{content:" \25BC";opacity:1}
</style>
<script>
document.addEventListener('DOMContentLoaded',function(){
    document.querySelectorAll('#deviceTable th[data-sort]').forEach(function(th){
        th.addEventListener('click',function(){
            var tbl=this.closest('table'), tbody=tbl.querySelector('tbody');
            var idx=Array.prototype.indexOf.call(this.parentNode.children,this);
            var type=this.getAttribute('data-sort'), asc=this.classList.contains('asc');
            tbl.querySelectorAll('th[data-sort]').forEach(function(h){h.classList.remove('asc','desc')});
            this.classList.add(asc?'desc':'asc');
            var rows=Array.from(tbody.querySelectorAll('tr'));
            rows.sort(function(a,b){
                var ta=a.children[idx], tb=b.children[idx];
                var va=ta.getAttribute('data-sort-value'), vb=tb.getAttribute('data-sort-value');
                if(va===null||vb===null){va=ta.textContent.trim();vb=tb.textContent.trim()}
                if(type==='int')return(parseInt(va)||0)-(parseInt(vb)||0);
                if(type==='float')return(parseFloat(va)||0)-(parseFloat(vb)||0);
                return String(va).localeCompare(String(vb));
            });
            if(asc)rows.reverse();
            rows.forEach(function(row){tbody.appendChild(row)});
        });
    });
});
</script>{/literal}
{include file="sections/footer.tpl"}
