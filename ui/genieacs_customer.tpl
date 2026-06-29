{include file="customer/header.tpl"}
{if isset($error)}
<div class="alert alert-warning">{$error}</div>
{elseif !$device}
<div class="alert alert-info">{Lang::T('No device found for your account.')}</div>
{else}
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">{Lang::T('Device Status')}</div>
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <tr>
                            <th>{Lang::T('Device ID')}</th>
                            <td>{$device._id|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Serial Number')}</th>
                            <td>{$device._deviceId._SerialNumber|default:'-'|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Manufacturer')}</th>
                            <td>{$device._deviceId._Manufacturer|default:'-'|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Model')}</th>
                            <td>{$device._deviceId._ProductClass|default:'-'|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Status')}</th>
                            <td>{if $online}<span class="label label-success">{Lang::T('Online')}</span>{else}<span class="label label-danger">{Lang::T('Offline')}</span>{/if}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Actions')}</th>
                            <td>
                                <a href="{$_url}plugin/genieacs_customer_reboot&id={$device._id|escape:'url'}" class="btn btn-warning btn-xs" onclick="return confirm('{Lang::T('Reboot this device?')}')">{Lang::T('Reboot')}</a>
                            </td>
                        </tr>
                        {if $deviceInfo.temperature neq 'N/A'}
                        <tr>
                            <th>{Lang::T('Temperature')}</th>
                            <td>{$deviceInfo.temperature}</td>
                        </tr>
                        {/if}
                        {if $deviceInfo.rx_power neq 'N/A'}
                        <tr>
                            <th>{Lang::T('RX Power')}</th>
                            <td>{$deviceInfo.rx_power}</td>
                        </tr>
                        {/if}
                        {if $deviceInfo.pppoe_username neq 'N/A'}
                        <tr>
                            <th>{Lang::T('PPPoE Username')}</th>
                            <td>{$deviceInfo.pppoe_username|escape:'html'}</td>
                        </tr>
                        {/if}
                        <tr>
                            <th>{Lang::T('Last Inform')}</th>
                            <td>{$device._lastInform|default:'-'|escape:'html'}</td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

{if $wlanConfigs|@count > 0}
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">{Lang::T('WiFi Configuration')}</div>
            <div class="panel-body">
                {foreach $wlanConfigs as $wlan}
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <tr>
                            <th>{Lang::T('SSID')}</th>
                            <td>{$wlan.ssid|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Password')}</th>
                            <td>{$wlan.password|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Security')}</th>
                            <td>{$wlan.security|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Channel')}</th>
                            <td>{$wlan.channel|escape:'html'}</td>
                        </tr>
                        <tr>
                            <th>{Lang::T('Band')}</th>
                            <td>{$wlan.band|default:$wlan.standard|escape:'html'}</td>
                        </tr>
                        {if isset($wlan.connected_devices) && $wlan.connected_devices !== ''}
                        <tr>
                            <th>{Lang::T('Connected Devices')}</th>
                            <td>{$wlan.connected_devices}</td>
                        </tr>
                        {/if}
                        <tr>
                            <th>{Lang::T('Actions')}</th>
                            <td>
                                <a href="{$_url}plugin/genieacs_customer_wlan_edit&id={$device._id|escape:'url'}" class="btn btn-info btn-xs">{Lang::T('WiFi Settings')}</a>
                            </td>
                        </tr>
                    </table>
                </div>
                {if !$wlan@last}<hr>{/if}
                {/foreach}
            </div>
        </div>
    </div>
</div>
{/if}
{/if}
{include file="customer/footer.tpl"}