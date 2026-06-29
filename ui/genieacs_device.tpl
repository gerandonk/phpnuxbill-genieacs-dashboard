{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="btn-group pull-right">
            <a href="{$_url}plugin/genieacs_device&id={$device._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-default btn-sm" title="{Lang::T('Refresh')}"><i class="glyphicon glyphicon-refresh"></i></a>
            <a href="{$_url}plugin/genieacs_reboot&id={$device._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-warning btn-sm" onclick="return confirm('{Lang::T('Reboot this device?')}')">{Lang::T('Reboot')}</a>
            <a href="{$_url}plugin/genieacs_summon&id={$device._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-success btn-sm" onclick="return confirm('{Lang::T('Summon this device?')}')">{Lang::T('Summon')}</a>
            <a href="{$_url}plugin/genieacs_devices{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-info btn-sm">{Lang::T('Back')}</a>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">{Lang::T('Basic Information')}</div>
            <div class="panel-body">
                <table class="table table-striped">
                    <tr>
                        <td><strong>{Lang::T('Device ID')}</strong></td>
                        <td>{$device._id|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Serial Number')}</strong></td>
                        <td>{$device._deviceId._SerialNumber|default:'-'|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Manufacturer')}</strong></td>
                        <td>{$device._deviceId._Manufacturer|default:'-'|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('OUI')}</strong></td>
                        <td>{$device._deviceId._OUI|default:'-'|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Product Class')}</strong></td>
                        <td>{$device._deviceId._ProductClass|default:'-'|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Software Version')}</strong></td>
                        <td>{$device.InternetGatewayDevice.DeviceInfo.SoftwareVersion._value|default:'-'|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Hardware Version')}</strong></td>
                        <td>{$device.InternetGatewayDevice.DeviceInfo.HardwareVersion._value|default:'-'|escape:'html'}</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">{Lang::T('Status')}</div>
            <div class="panel-body">
                <table class="table table-striped">
                    <tr>
                        <td><strong>{Lang::T('Status')}</strong></td>
                        <td>
                            {assign var="lastInform" value=$device._lastInform|default:''}
                            {if $lastInform && (time() - strtotime($lastInform)) < 300}
                                <span class="label label-success">{Lang::T('Online')}</span>
                            {else}
                                <span class="label label-danger">{Lang::T('Offline')}</span>
                            {/if}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Last Inform')}</strong></td>
                        <td>{$device._lastInform|default:'-'|escape:'html'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('WAN IP')}</strong></td>
                        <td>
                            {assign var="ip" value=''}
                            {for $idx=1 to 8}
                                {assign var="ppp" value=$device.InternetGatewayDevice.WANDevice.1.WANConnectionDevice[$idx].WANPPPConnection.1.ExternalIPAddress._value|default:''}
                                {assign var="ipc" value=$device.InternetGatewayDevice.WANDevice.1.WANConnectionDevice[$idx].WANIPConnection.1.ExternalIPAddress._value|default:''}
                                {if $ppp && $ppp != '0.0.0.0'}{assign var="ip" value=$ppp}{break}{/if}
                                {if $ipc && $ipc != '0.0.0.0'}{assign var="ip" value=$ipc}{break}{/if}
                            {/for}
                            {if !$ip}{assign var="ip" value=$device.Device.IP.Interface.1.IPv4Address.1.IPAddress._value|default:''}{/if}
                            {if $ip && $ip != '0.0.0.0'}{$ip|escape:'html'}{else}-{/if}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('RX Power')}</strong></td>
                        <td>
                            {if $rxPowerRaw !== null}
                                {if $rxPowerRaw <= -33.1}
                                    <span class="label label-default">{$rxPower|escape:'html'}</span>
                                {elseif $rxPowerRaw < -28}
                                    <span class="label label-danger">{$rxPower|escape:'html'}</span>
                                {elseif $rxPowerRaw <= -23}
                                    <span class="label label-warning">{$rxPower|escape:'html'}</span>
                                {elseif $rxPowerRaw <= -17}
                                    <span class="label label-success">{$rxPower|escape:'html'}</span>
                                {else}
                                    <span class="label" style="background:#e91e63;color:#fff">{$rxPower|escape:'html'}</span>
                                {/if}
                            {else}
                                {$rxPower|default:'-'|escape:'html'}
                            {/if}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Uptime')}</strong></td>
                        <td>{$uptime|default:'-'}</td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Temperature')}</strong></td>
                        <td>
                            {if $temperatureRaw !== null}
                                {if $temperatureRaw < 40}
                                    <span class="label label-success">{$temperature|escape:'html'}</span>
                                {elseif $temperatureRaw <= 50}
                                    <span class="label label-warning">{$temperature|escape:'html'}</span>
                                {else}
                                    <span class="label label-danger">{$temperature|escape:'html'}</span>
                                {/if}
                            {else}
                                {$temperature|default:'-'|escape:'html'}
                            {/if}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>{Lang::T('Tags')}</strong></td>
                        <td>
                            {assign var="tags" value=$device._tags|default:[]}
                            {if is_array($tags) && $tags|@count > 0}
                                {foreach $tags as $tag}
                                    <span class="label label-info">{$tag|escape:'html'}</span>
                                {/foreach}
                            {else}
                                -
                            {/if}
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="panel panel-hovered mb20 panel-green">
            <div class="panel-heading">
                {Lang::T('WAN Connections')}
                <div class="pull-right" style="display:flex;gap:4px">
                    <a href="{$_url}plugin/genieacs_device_wan&id={$device._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-primary btn-xs">{Lang::T('Edit WAN')}</a>
                    <a href="{$_url}plugin/genieacs_device_wan&id={$device._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}&add=1" class="btn btn-success btn-xs">{Lang::T('Add WAN')}</a>
                </div>
            </div>
            <div class="panel-body">
                {assign var="foundWan" value=0}
                {for $idx=1 to 8}
                    {assign var="ppp" value=$device.InternetGatewayDevice.WANDevice.1.WANConnectionDevice[$idx].WANPPPConnection.1}
                    {assign var="ipc" value=$device.InternetGatewayDevice.WANDevice.1.WANConnectionDevice[$idx].WANIPConnection.1}
                    {if $ppp || $ipc}
                        {assign var="foundWan" value=1}
                        {assign var="conn" value=$ppp|default:$ipc}
                        <div style="margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px solid #eee;">
                            <strong>#{if $idx} {$idx} {/if}{if $ppp}PPP{else}IP{/if}</strong><br>
                            {if $ppp.Username._value}<small>{Lang::T('User')}: {$ppp.Username._value|escape:'html'}</small><br>{/if}
                            {if $ppp.Password._value}<small>{Lang::T('Pass')}: {$ppp.Password._value|escape:'html'}</small><br>{/if}
                            {if $conn.ExternalIPAddress._value}<small>{Lang::T('IP')}: {$conn.ExternalIPAddress._value|escape:'html'}</small><br>{/if}
                            {if $conn.DefaultGateway._value}<small>{Lang::T('Gateway')}: {$conn.DefaultGateway._value|escape:'html'}</small><br>{/if}
                            {if $conn.DNSServers._value}<small>{Lang::T('DNS')}: {$conn.DNSServers._value|escape:'html'}</small><br>{/if}
                            {if $conn.ConnectionType._value}<small>{Lang::T('Type')}: {$conn.ConnectionType._value|escape:'html'}</small>{/if}
                        </div>
                    {/if}
                {/for}
                {if !$foundWan}
                    <p>{Lang::T('No WAN connection data available.')}</p>
                {/if}
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="panel panel-hovered mb20 panel-green">
            <div class="panel-heading">
                {Lang::T('WLAN Configurations')}
                <div class="pull-right">
                    <a href="{$_url}plugin/genieacs_device_wlan&id={$device._id|escape:'url'}{if $activeHost}&host_id={$activeHost.id}{/if}" class="btn btn-primary btn-xs">{Lang::T('Edit WLAN')}</a>
                </div>
            </div>
            <div class="panel-body">
                {assign var="foundWlan" value=0}
                {foreach $wlanConfigs as $wlan}
                    {assign var="foundWlan" value=1}
                    <div style="margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px solid #eee;">
                        <strong>{$wlan.ssid|default:'-'|escape:'html'} <small>(#{$wlan.index})</small></strong><br>
                        {if $wlan.password}<small>{Lang::T('Pass')}: {$wlan.password|escape:'html'}</small><br>{/if}
                        {if $wlan.mac}<small>{Lang::T('BSSID')}: {$wlan.mac|escape:'html'}</small><br>{/if}
                        {if $wlan.channel}<small>{Lang::T('Channel')}: {$wlan.channel|escape:'html'}</small><br>{/if}
                        {if $wlan.beacon_type}<small>{Lang::T('Security')}: {$wlan.beacon_type|escape:'html'}</small><br>{/if}
                        {if $wlan.standard}<small>{Lang::T('Standard')}: {$wlan.standard|escape:'html'}</small><br>{/if}
                        {if $wlan.max_bitrate}<small>{Lang::T('Max Rate')}: {$wlan.max_bitrate|escape:'html'}</small>{/if}
                        {if isset($wlan.connected_devices)}<br><small>{Lang::T('Connected')}: {$wlan.connected_devices}</small>{/if}
                    </div>
                {foreachelse}
                    <p>{Lang::T('No WLAN configuration data available.')}</p>
                {/foreach}
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">{Lang::T('Raw Device Data (JSON)')}</div>
            <div class="panel-body">
                <pre style="max-height: 400px; overflow-y: auto;">{$device|json_encode:JSON_PRETTY_PRINT|escape:'html'}</pre>
            </div>
        </div>
    </div>
</div>
{include file="sections/footer.tpl"}
