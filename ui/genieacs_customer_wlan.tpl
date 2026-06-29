{include file="customer/header.tpl"}
<div class="row">
    <div class="col-md-12">
        <a href="{$_url}plugin/genieacs_customer_dashboard" class="btn btn-info btn-sm pull-right">{Lang::T('Back')}</a>
        <h3>{Lang::T('WLAN Configuration')}</h3>
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
                            <table class="table table-bordered">
                                <tr><th>{Lang::T('SSID')}</th><td>{$wlan.ssid|default:'-'|escape:'html'}</td></tr>
                                <tr><th>{Lang::T('Channel')}</th><td>{$wlan.channel|default:'-'|escape:'html'}</td></tr>
                                <tr><th>{Lang::T('Security')}</th><td>{$wlan.security|default:$wlan.beacon_type|escape:'html'}</td></tr>
                                {if $wlan.password}
                                <tr><th>{Lang::T('Current Password')}</th><td><code>{$wlan.password|escape:'html'}</code></td></tr>
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
                                    <input type="text" name="password" class="form-control" value="" placeholder="{Lang::T('Leave empty to keep current')}">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">{Lang::T('Security Mode')}</label>
                                <div class="col-md-9">
                                    <select name="security_mode" class="form-control">
                                        <option value="WPA2PSK"{if $wlan.beacon_type == '11i'} selected{/if}>WPA2-PSK</option>
                                        <option value="WPAPSK"{if $wlan.beacon_type == 'WPA'} selected{/if}>WPA-PSK</option>
                                        <option value="WPA2PSKWPAPSK"{if $wlan.beacon_type == 'WPAand11i'} selected{/if}>WPA/WPA2-PSK</option>
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
            <div class="panel-heading">{Lang::T('WLAN Configuration')}</div>
            <div class="panel-body">
                <p>{Lang::T('No WLAN configuration data available for this device.')}</p>
            </div>
        </div>
    </div>
</div>
{/foreach}
{include file="customer/footer.tpl"}