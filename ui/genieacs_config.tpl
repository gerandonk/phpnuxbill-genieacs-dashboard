{include file="sections/header.tpl"}
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">
                <div class="pull-right">
                    <a href="{$_url}plugin/genieacs_config&action=add" class="btn btn-success btn-xs">{Lang::T('Add Host')}</a>
                </div>
                {Lang::T('GenieACS Hosts')}
            </div>
            <div class="panel-body">
                {if $hosts|@count > 0}
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>{Lang::T('Active')}</th>
                                <th>{Lang::T('Name')}</th>
                                <th>{Lang::T('Host')}</th>
                                <th>{Lang::T('Port')}</th>
                                <th>{Lang::T('Username')}</th>
                                <th>{Lang::T('Actions')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $hosts as $h}
                            <tr>
                                <td>
                                    {if $h.active}
                                        <span class="label label-success">{Lang::T('Active')}</span>
                                    {else}
                                        <a href="{$_url}plugin/genieacs_config&action=setactive&id={$h.id}" class="btn btn-default btn-xs">{Lang::T('Set Active')}</a>
                                    {/if}
                                </td>
                                <td>{$h.name|escape:'html'}</td>
                                <td>{$h.host|escape:'html'}</td>
                                <td>{$h.port}</td>
                                <td>{$h.username|default:''|escape:'html'}</td>
                                <td>
                                    <a href="{$_url}plugin/genieacs_config&action=test&id={$h.id}" class="btn btn-info btn-xs">{Lang::T('Test')}</a>
                                    <a href="{$_url}plugin/genieacs_config&action=edit&id={$h.id}" class="btn btn-primary btn-xs">{Lang::T('Edit')}</a>
                                    <a href="{$_url}plugin/genieacs_config&action=delete&id={$h.id}" class="btn btn-danger btn-xs" onclick="return confirm('{Lang::T('Delete this host?')}')">{Lang::T('Delete')}</a>
                                </td>
                            </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
                {else}
                <div class="alert alert-info">{Lang::T('No hosts configured. Click "Add Host" to add one.')}</div>
                {/if}
            </div>
        </div>

        {if $editHost || $action == 'add'}
        <div class="panel panel-hovered mb20 panel-primary">
            <div class="panel-heading">
                {if $editHost}{Lang::T('Edit Host')}{else}{Lang::T('Add Host')}{/if}
            </div>
            <div class="panel-body">
                <form class="form-horizontal" method="post">
                    {if $editHost}
                    <input type="hidden" name="id" value="{$editHost.id}">
                    {/if}
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Name')}</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" name="name" value="{$editHost.name|default:''|escape:'html'}" placeholder="My GenieACS" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Host')}</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" name="host" value="{$editHost.host|default:''|escape:'html'}" placeholder="192.168.1.100 or domain.com" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Port')}</label>
                        <div class="col-md-3">
                            <input type="number" class="form-control" name="port" value="{$editHost.port|default:'7557'}" placeholder="7557">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Username')}</label>
                        <div class="col-md-6">
                            <input type="text" class="form-control" name="username" value="{$editHost.username|default:''|escape:'html'}" placeholder="admin (optional)">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-2 control-label">{Lang::T('Password')}</label>
                        <div class="col-md-6">
                            <input type="password" class="form-control" name="password" value="{$editHost.password|default:''|escape:'html'}">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-6 col-md-offset-2">
                            <button type="submit" name="save" value="save" class="btn btn-primary">{Lang::T('Save')}</button>
                            <a href="{$_url}plugin/genieacs_config" class="btn btn-default">{Lang::T('Cancel')}</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        {/if}
    </div>
</div>
{include file="sections/footer.tpl"}
