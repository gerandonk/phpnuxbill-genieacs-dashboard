{include file="sections/header.tpl"}
<div class="row">
    <div class="col-md-12">
        <div class="btn-group pull-right">
            <a href="{$_url}plugin/genieacs_device&id={$deviceId|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info btn-sm">{Lang::T('Back to Device')}</a>
        </div>
        <h3>{Lang::T('WAN Configuration')}: {$deviceId|escape:'html'}</h3>
    </div>
</div>

{if $saved}
    <div class="alert alert-info">{$saved}</div>
{/if}

{if $addMode}
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-success">
            <div class="panel-heading">{Lang::T('Add New WAN Connection')}</div>
            <div class="panel-body">
                {if $availIndex}
                <form method="post" action="" class="form-horizontal">
                    <input type="hidden" name="connection_index" value="{$availIndex}">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('Connection Index')}</label>
                                <div class="col-md-9">
                                    <p class="form-control-static"><strong>{$availIndex}</strong> ({Lang::T('available')})</p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('Connection Type')}</label>
                                <div class="col-md-9">
                                    <select name="connection_type" class="form-control">
                                        <option value="ppp">{Lang::T('PPP (PPPoE)')}</option>
                                        <option value="ip">{Lang::T('IP (DHCP/Static)')}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('Username')}</label>
                                <div class="col-md-9">
                                    <input type="text" name="username" class="form-control" placeholder="{Lang::T('PPPoE username')}">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('Password')}</label>
                                <div class="col-md-9">
                                    <input type="text" name="password" class="form-control" placeholder="{Lang::T('PPPoE password')}">
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('VLAN ID')}</label>
                                <div class="col-md-9">
                                    <input type="number" name="vlan" class="form-control" placeholder="{Lang::T('e.g. 10')}">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('NAT Enabled')}</label>
                                <div class="col-md-9">
                                    <select name="nat" class="form-control">
                                        <option value="">{Lang::T('Leave unchanged')}</option>
                                        <option value="1">{Lang::T('Enable')}</option>
                                        <option value="0">{Lang::T('Disable')}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-offset-3 col-md-9">
                                    <button type="submit" name="save_wan" value="1" class="btn btn-success">{Lang::T('Add WAN Connection')}</button>
                                    <a href="{$_url}plugin/genieacs_device_wan&id={$deviceId|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-default">{Lang::T('Cancel')}</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
                {else}
                <div class="alert alert-warning">{Lang::T('No available connection indexes (all 8 in use).')}</div>
                {/if}
            </div>
        </div>
    </div>
</div>
{/if}

{foreach $wanConnections as $wan}
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-hovered mb20 panel-primary">
                <div class="panel-heading">{Lang::T('WAN Connection')} {$wan.index} ({$wan.type|upper})</div>
                <div class="panel-body">
                    <form method="post" action="" class="form-horizontal">
                        <input type="hidden" name="connection_index" value="{$wan.index}">
                        <input type="hidden" name="connection_type" value="{$wan.type}">
                        <div class="row">
                            <div class="col-md-6">
                                <table class="table table-striped">
                                    <tr>
                                        <td><strong>{Lang::T('Type')}</strong></td>
                                        <td>{$wan.type|upper}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Connection Type')}</strong></td>
                                        <td>{$wan.connection_type|default:'-'|escape:'html'}</td>
                                    </tr>
                                    {if $wan.type == 'ppp' && $wan.password}
                                    <tr>
                                        <td><strong>{Lang::T('Current Password')}</strong></td>
                                        <td><code>{$wan.password|escape:'html'}</code></td>
                                    </tr>
                                    {/if}
                                    <tr>
                                        <td><strong>{Lang::T('External IP')}</strong></td>
                                        <td>{$wan.external_ip|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Gateway')}</strong></td>
                                        <td>{$wan.gateway|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Subnet Mask')}</strong></td>
                                        <td>{$wan.subnet|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('DNS Servers')}</strong></td>
                                        <td>{$wan.dns|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('NAT Enabled')}</strong></td>
                                        <td>{if $wan.nat}{Lang::T('Yes')}{else}{Lang::T('No')}{/if}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Enabled')}</strong></td>
                                        <td>{if $wan.enable}{Lang::T('Yes')}{else}{Lang::T('No')}{/if}</td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('Username')}</label>
                                    <div class="col-md-9">
                                        <input type="text" name="username" class="form-control" value="{$wan.username|default:''|escape:'html'}">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('Password')}</label>
                                    <div class="col-md-9">
                                        <input type="text" name="password" class="form-control" value="">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('VLAN ID')}</label>
                                    <div class="col-md-9">
                                        <input type="number" name="vlan" class="form-control">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('NAT Enabled')}</label>
                                    <div class="col-md-9">
                                        <select name="nat" class="form-control">
                                            <option value="">{Lang::T('Leave unchanged')}</option>
                                            <option value="1">{Lang::T('Enable')}</option>
                                            <option value="0">{Lang::T('Disable')}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-offset-3 col-md-9">
                                        <button type="submit" name="save_wan" value="1" class="btn btn-success">{Lang::T('Update WAN')}</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
{foreachelse}
    {if !$addMode}
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-hovered mb20 panel-warning">
                <div class="panel-heading">{Lang::T('WAN Connections')}</div>
                <div class="panel-body">
                    <p>{Lang::T('No WAN connection data available for this device.')}</p>
                </div>
            </div>
        </div>
    </div>
    {/if}
{/foreach}

{include file="sections/footer.tpl"}
