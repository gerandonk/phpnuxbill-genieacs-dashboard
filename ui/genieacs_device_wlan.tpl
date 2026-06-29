{include file="sections/header.tpl"}
<div class="row">
    <div class="col-md-12">
        <div class="btn-group pull-right">
            <a href="{$_url}plugin/genieacs_device&id={$deviceId|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info btn-sm">{Lang::T('Back to Device')}</a>
        </div>
        <h3>{Lang::T('WLAN Configuration')}: {$deviceId|escape:'html'}</h3>
    </div>
</div>

{if $saved}
    <div class="alert alert-info">{$saved}</div>
{/if}

{foreach $wlanConfigs as $wlan}
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-hovered mb20 panel-primary">
                <div class="panel-heading">{Lang::T('WLAN')} {$wlan.index}</div>
                <div class="panel-body">
                    <form method="post" action="" class="form-horizontal">
                        <input type="hidden" name="wlan_index" value="{$wlan.index}">
                        <div class="row">
                            <div class="col-md-6">
                                <table class="table table-striped">
                                    <tr>
                                        <td><strong>{Lang::T('SSID')}</strong></td>
                                        <td>{$wlan.ssid|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Channel')}</strong></td>
                                        <td>{$wlan.channel|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Standard')}</strong></td>
                                        <td>{$wlan.standard|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Max Bitrate')}</strong></td>
                                        <td>{$wlan.max_bitrate|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('BSSID')}</strong></td>
                                        <td>{$wlan.mac|default:'-'|escape:'html'}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>{Lang::T('Beacon Type')}</strong></td>
                                        <td>{$wlan.beacon_type|default:'-'|escape:'html'}</td>
                                    </tr>
                                    {if $wlan.password}
                                    <tr>
                                        <td><strong>{Lang::T('Current Password')}</strong></td>
                                        <td><code>{$wlan.password|escape:'html'}</code></td>
                                    </tr>
                                    {/if}
                                    <tr>
                                        <td><strong>{Lang::T('Enabled')}</strong></td>
                                        <td>{if $wlan.enable}{Lang::T('Yes')}{else}{Lang::T('No')}{/if}</td>
                                    </tr>
                                    {if isset($wlan.connected_devices)}
                                    <tr>
                                        <td><strong>{Lang::T('Connected Devices')}</strong></td>
                                        <td>{$wlan.connected_devices}</td>
                                    </tr>
                                    {/if}
                                </table>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('SSID')}</label>
                                    <div class="col-md-9">
                                        <input type="text" name="ssid" class="form-control" value="{$wlan.ssid|default:''|escape:'html'}" required>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('Password')}</label>
                                    <div class="col-md-9">
                                        <input type="text" name="password" class="form-control" value="">
                                        <p class="help-block">{Lang::T('Leave empty to keep current')}</p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-3 control-label">{Lang::T('Security Mode')}</label>
                                    <div class="col-md-9">
                                        <select name="security_mode" class="form-control">
                                            <option value="WPA2PSK"{if $wlan.beacon_type == '11i'} selected{/if}>{Lang::T('WPA2-PSK')}</option>
                                            <option value="WPAPSK"{if $wlan.beacon_type == 'WPA'} selected{/if}>{Lang::T('WPA-PSK')}</option>
                                            <option value="WPA2PSKWPAPSK"{if $wlan.beacon_type == 'WPAand11i'} selected{/if}>{Lang::T('WPA/WPA2-PSK')}</option>
                                            <option value="None"{if $wlan.beacon_type == 'Basic' || $wlan.beacon_type == 'None'} selected{/if}>{Lang::T('Open')}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-offset-3 col-md-9">
                                        <button type="submit" name="save_wlan" value="1" class="btn btn-success">{Lang::T('Update WLAN')}</button>
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
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-hovered mb20 panel-warning">
                <div class="panel-heading">{Lang::T('WLAN Configurations')}</div>
                <div class="panel-body">
                    <p>{Lang::T('No WLAN configuration data available for this device.')}</p>
                </div>
            </div>
        </div>
    </div>
{/foreach}

{include file="sections/footer.tpl"}
