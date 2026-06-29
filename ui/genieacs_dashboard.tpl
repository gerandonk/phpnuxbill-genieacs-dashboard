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
        <a href="{$_url}plugin/genieacs_dashboard{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-default btn-sm pull-right" title="{Lang::T('Refresh')}"><i class="glyphicon glyphicon-refresh"></i></a>
        <a href="{$_url}plugin/genieacs_config" class="btn btn-default btn-sm pull-right" title="{Lang::T('Settings')}"><i class="glyphicon glyphicon-cog"></i></a>
        <form class="form-inline pull-right" method="get" action="{$_url}plugin/genieacs_dashboard">
            <input type="hidden" name="_route" value="plugin/genieacs_dashboard">
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
        <h3>{if $activeHost}{$activeHost.name|escape:'html'}{else}{Lang::T('GenieACS Dashboard')}{/if}</h3>
    </div>
</div>

{if !$activeHost}
<div class="alert alert-info">{Lang::T('Select a host above to view its dashboard.')}</div>
{else}
<div class="row">
    {literal}<style>
    .stat-card .panel-body{color:#fff}
    .stat-card.stat-total .panel-body{background:#337ab7}
    .stat-card.stat-online .panel-body{background:#5cb85c}
    .stat-card.stat-offline .panel-body{background:#d9534f}
    .stat-card.stat-all .panel-body{background:#5bc0de}
    .stat-card a{color:#fff;text-decoration:underline}
    </style>{/literal}
    <div class="col-md-3 col-sm-6">
        <div class="panel panel-hovered panel-stacked mb20 panel-primary stat-card stat-total">
            <div class="panel-body text-center">
                <h3>{$stats.total}</h3>
                <p>{Lang::T('Total Devices')}</p>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="panel panel-hovered panel-stacked mb20 panel-success stat-card stat-online">
            <div class="panel-body text-center">
                <h3>{$stats.online}</h3>
                <p>{Lang::T('Online')}</p>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="panel panel-hovered panel-stacked mb20 panel-danger stat-card stat-offline">
            <div class="panel-body text-center">
                <h3>{$stats.offline}</h3>
                <p><a href="#offlineSection" style="color:#fff;text-decoration:underline">{Lang::T('Offline')}</a></p>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="panel panel-hovered panel-stacked mb20 panel-info stat-card stat-all">
            <div class="panel-body text-center">
                <h3><a href="{$_url}plugin/genieacs_devices{if $activeHost}&host_id={$activeHost.id}{/if}">{Lang::T('View All')}</a></h3>
                <p>{Lang::T('Device List')}</p>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">{Lang::T('Recent Devices')}</div>
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>{Lang::T('Device ID')}</th>
                                <th>{Lang::T('Serial Number')}</th>
                                <th>{Lang::T('Manufacturer')}</th>
                                <th>{Lang::T('Product Class')}</th>
                                <th>{Lang::T('Status')}</th>
                                <th>{Lang::T('Last Inform')}</th>
                                <th>{Lang::T('Manage')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $devices as $d}
                            <tr>
                                <td><a href="{$_url}plugin/genieacs_device&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}">{$d._id|escape:'html'}</a></td>
                                <td>{$d._deviceId._SerialNumber|default:'-'|escape:'html'}</td>
                                <td>{$d._deviceId._Manufacturer|default:'-'|escape:'html'}</td>
                                <td>{$d._deviceId._ProductClass|default:'-'|escape:'html'}</td>
                                <td>
                                    {assign var="lastInform" value=$d._lastInform|default:''}
                                    {if $lastInform && (time() - strtotime($lastInform)) < 300}
                                        <span class="label label-success">{Lang::T('Online')}</span>
                                    {else}
                                        <span class="label label-danger">{Lang::T('Offline')}</span>
                                    {/if}
                                </td>
                                <td>{$d._lastInform|default:'-'|escape:'html'}</td>
                                <td>
                                    <a href="{$_url}plugin/genieacs_device&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info btn-xs">{Lang::T('Detail')}</a>
                                    <a href="{$_url}plugin/genieacs_reboot&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-warning btn-xs" onclick="return confirm('{Lang::T('Reboot this device?')}')">{Lang::T('Reboot')}</a>
                                </td>
                            </tr>
                            {foreachelse}
                            <tr>
                                <td colspan="7" class="text-center">{Lang::T('No devices found')}</td>
                            </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
{if $offlineDevices|@count > 0}
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-danger" id="offlineSection">
            <div class="panel-heading">{Lang::T('Offline Devices')} ({$offlineDevices|@count})</div>
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>{Lang::T('Device ID')}</th>
                                <th>{Lang::T('Serial Number')}</th>
                                <th>{Lang::T('Manufacturer')}</th>
                                <th>{Lang::T('Product Class')}</th>
                                <th>{Lang::T('Last Inform')}</th>
                                <th>{Lang::T('Manage')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $offlineDevices as $d}
                            <tr>
                                <td><a href="{$_url}plugin/genieacs_device&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}">{$d._id|escape:'html'}</a></td>
                                <td>{$d._deviceId._SerialNumber|default:'-'|escape:'html'}</td>
                                <td>{$d._deviceId._Manufacturer|default:'-'|escape:'html'}</td>
                                <td>{$d._deviceId._ProductClass|default:'-'|escape:'html'}</td>
                                <td>{$d._lastInform|default:'-'|escape:'html'}</td>
                                <td>
                                    <a href="{$_url}plugin/genieacs_device&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info btn-xs">{Lang::T('Detail')}</a>
                                    <a href="{$_url}plugin/genieacs_summon&id={$d._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-success btn-xs" onclick="return confirm('{Lang::T('Summon this device?')}')">{Lang::T('Summon')}</a>
                                </td>
                            </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
{/if}
{/if}
{/if}
{include file="sections/footer.tpl"}
