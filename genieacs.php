<?php

/**
 * 
 * PHP Mikrotik Billing (https://github.com/hotspotbilling/phpnuxbill/)
 *
 * GenieAcs Dashboard Plugin for PHP Mikrotik Billing
 *
 * @author: Gerandonk Mods <noc@igrwifi.my.id>
 * Website: https://igrwifi.my.id/
 * GitHub: https://github.com/gerandonk/
 * Telegram: https://t.me/sklitinov/
 *
 **/

register_menu("GenieACS", true, "genieacs_dashboard", 'AFTER_RADIUS', 'glyphicon glyphicon-signal', 'Free Version', 'yellow', ['SuperAdmin', 'Admin']);
register_menu("My Device", false, "genieacs_customer_dashboard", 'AFTER_DASHBOARD', 'glyphicon glyphicon-signal');

class GenieACSClient
{
    private $host;
    private $port;
    private $username;
    private $password;
    private $baseUrl;

    public function __construct($host = null, $port = 7557, $username = null, $password = null)
    {
        $this->host = $host;
        $this->port = $port;
        $this->username = $username;
        $this->password = $password;
        $this->baseUrl = "http://{$this->host}:{$this->port}";
    }

    private function request($endpoint, $method = 'GET', $data = null)
    {
        $url = $this->baseUrl . $endpoint;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 60);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);

        if (!empty($this->username)) {
            curl_setopt($ch, CURLOPT_USERPWD, "{$this->username}:{$this->password}");
        }

        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            if ($data) {
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
                curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            }
        } elseif ($method === 'PUT') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
            if ($data) {
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
                curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            }
        } elseif ($method === 'DELETE') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            return ['success' => false, 'error' => $error];
        }

        return [
            'success' => $httpCode >= 200 && $httpCode < 300,
            'data' => json_decode($response, true),
            'http_code' => $httpCode,
        ];
    }

    public function testConnection()
    {
        $result = $this->request('/devices?limit=1');
        return $result['success'];
    }

    public function getDevices($query = [], $limit = 100, $skip = 0)
    {
        $params = [];
        if (!empty($query)) {
            $params[] = 'query=' . urlencode(json_encode($query));
        }
        if ($limit > 0) {
            $params[] = 'limit=' . $limit;
        }
        if ($skip > 0) {
            $params[] = 'skip=' . $skip;
        }
        $queryString = !empty($params) ? '?' . implode('&', $params) : '';
        return $this->request('/devices/' . $queryString);
    }

    public function getDevice($deviceId)
    {
        $query = ['_id' => $deviceId];
        $queryString = '?query=' . urlencode(json_encode($query));
        $result = $this->request('/devices/' . $queryString);
        if ($result['success'] && !empty($result['data'])) {
            return ['success' => true, 'data' => $result['data'][0]];
        }
        return ['success' => false, 'error' => 'Device not found'];
    }

    public function rebootDevice($deviceId)
    {
        $encodedId = rawurlencode($deviceId);
        $endpoint = "/devices/{$encodedId}/tasks?connection_request";
        $data = ['name' => 'reboot'];
        return $this->request($endpoint, 'POST', $data);
    }

    public function summonDevice($deviceId)
    {
        $encodedId = rawurlencode($deviceId);
        $endpoint = "/devices/{$encodedId}/tasks?connection_request";
        return $this->request($endpoint, 'POST');
    }

    public function getDeviceCount()
    {
        $result = $this->request('/devices/?query=' . urlencode(json_encode([])));
        if ($result['success'] && isset($result['data'])) {
            return count($result['data']);
        }
        return 0;
    }

    public function setParameterValues($deviceId, $parameters, $timeout = 3000)
    {
        $encodedId = rawurlencode($deviceId);
        $endpoint = "/devices/{$encodedId}/tasks?timeout={$timeout}&connection_request";
        $data = [
            'name' => 'setParameterValues',
            'parameterValues' => $parameters
        ];
        return $this->request($endpoint, 'POST', $data);
    }
}

function genieacs_get_hosts()
{
    global $config;
    $raw = $config['genieacs_hosts'] ?? '[]';
    $hosts = json_decode($raw, true);
    if (!is_array($hosts)) {
        $hosts = [];
    }
    return $hosts;
}

function genieacs_save_hosts($hosts)
{
    $d = ORM::for_table('tbl_appconfig')->where('setting', 'genieacs_hosts')->find_one();
    if ($d) {
        $d->value = json_encode($hosts);
        $d->save();
    } else {
        $d = ORM::for_table('tbl_appconfig')->create();
        $d->setting = 'genieacs_hosts';
        $d->value = json_encode($hosts);
        $d->save();
    }
}

function genieacs_extract_device_info($d)
{
    $pppoe = 'N/A';
    for ($i = 1; $i <= 8; $i++) {
        $u = $d['InternetGatewayDevice']['WANDevice']['1']['WANConnectionDevice'][$i]['WANPPPConnection']['1']['Username']['_value'] ?? null;
        if ($u && $u !== '' && $u !== 'N/A') {
            $pppoe = $u;
            break;
        }
    }

    $connUrl = $d['InternetGatewayDevice']['ManagementServer']['ConnectionRequestURL']['_value'] ?? $d['Device']['ManagementServer']['ConnectionRequestURL']['_value'] ?? null;
    $tr069ip = 'N/A';
    if ($connUrl && preg_match('/https?:\/\/([^:\/]+)/', $connUrl, $m)) {
        $tr069ip = $m[1];
    }

    $rxPowerRaw = null;
    $rxPower = $d['VirtualParameters']['RXPower']['_value'] ?? $d['InternetGatewayDevice']['WANDevice']['1']['X_CT-COM_EponInterfaceConfig']['RXPower']['_value'] ?? $d['Device']['Optical']['Interface']['1']['RxPower']['_value'] ?? null;
    if ($rxPower !== null && is_numeric($rxPower)) {
        $rx = floatval($rxPower);
        if ($rx > 100) {
            $rx = ($rx / 100) - 40;
        }
        $rxPowerRaw = $rx;
        $rxPower = number_format($rx, 2) . ' dBm';
    } else {
        $rxPower = 'N/A';
    }

    $tempRaw = null;
    $temp = $d['VirtualParameters']['gettemp']['_value'] ?? $d['InternetGatewayDevice']['WANDevice']['1']['X_CT-COM_EponInterfaceConfig']['TransceiverTemperature']['_value'] ?? $d['VirtualParameters']['Temperature']['_value'] ?? $d['InternetGatewayDevice']['DeviceInfo']['Temperature']['_value'] ?? null;
    if ($temp !== null && is_numeric($temp)) {
        $t = floatval($temp);
        if ($t > 1000) {
            $t = $t / 256;
        }
        $tempRaw = $t;
        $temp = number_format($t, 1) . ' °C';
    } else {
        $temp = 'N/A';
    }

    $fullname = '';
    if ($pppoe !== 'N/A') {
        $cust = ORM::for_table('tbl_customers')->where('pppoe_username', $pppoe)->find_one();
        if (!$cust) {
            $cust = ORM::for_table('tbl_customers')->where('username', $pppoe)->find_one();
        }
        if ($cust) {
            $fullname = $cust['fullname'];
        }
    }

    $connectedDevices = 0;
    $wlanCfgs = genieacs_extract_wlan_configs($d);
    foreach ($wlanCfgs as $wc) {
        if (isset($wc['connected_devices']) && is_numeric($wc['connected_devices'])) {
            $connectedDevices += intval($wc['connected_devices']);
        }
    }

    return [
        'pppoe_username' => $pppoe,
        'tr069_ip' => $tr069ip,
        'temperature' => $temp,
        'temperature_raw' => $tempRaw,
        'rx_power' => $rxPower,
        'rx_power_raw' => $rxPowerRaw,
        'fullname' => $fullname,
        'connected_devices' => $connectedDevices,
    ];
}

function genieacs_load_config($hostId = null)
{
    $hosts = genieacs_get_hosts();
    if (empty($hosts)) {
        return null;
    }
    if ($hostId) {
        $found = null;
        foreach ($hosts as $h) {
            if ($h['id'] == $hostId) {
                $found = $h;
                break;
            }
        }
        if (!$found) {
            return null;
        }
        return new GenieACSClient($found['host'], (int)$found['port'], $found['username'] ?? '', $found['password'] ?? '');
    }
    $active = null;
    foreach ($hosts as $h) {
        if (!empty($h['active'])) {
            $active = $h;
            break;
        }
    }
    if (!$active) {
        $active = $hosts[0] ?? null;
    }
    if (!$active) {
        return null;
    }
    return new GenieACSClient($active['host'], (int)$active['port'], $active['username'] ?? '', $active['password'] ?? '');
}

function genieacs_config()
{
    global $ui, $config, $admin;
    _admin();

    $action = _get('action', '');

    if ($action == 'add' && _post('save')) {
        $hosts = genieacs_get_hosts();
        $id = uniqid();
        $hosts[] = [
            'id' => $id,
            'name' => _post('name'),
            'host' => _post('host'),
            'port' => (int)_post('port', 7557),
            'username' => _post('username'),
            'password' => _post('password'),
            'active' => count($hosts) == 0,
        ];
        genieacs_save_hosts($hosts);
        r2(U . 'plugin/genieacs_config', 's', 'Host added');
    }

    if ($action == 'edit' && _post('save')) {
        $hostId = _post('id');
        $hosts = genieacs_get_hosts();
        foreach ($hosts as &$h) {
            if ($h['id'] == $hostId) {
                $h['name'] = _post('name');
                $h['host'] = _post('host');
                $h['port'] = (int)_post('port', 7557);
                $h['username'] = _post('username');
                $h['password'] = _post('password');
                break;
            }
        }
        genieacs_save_hosts($hosts);
        r2(U . 'plugin/genieacs_config', 's', 'Host updated');
    }

    if ($action == 'test') {
        $hostId = _get('id');
        $hosts = genieacs_get_hosts();
        $found = null;
        foreach ($hosts as $h) {
            if ($h['id'] == $hostId) {
                $found = $h;
                break;
            }
        }
        if ($found) {
            $client = new GenieACSClient($found['host'], (int)$found['port'], $found['username'] ?? '', $found['password'] ?? '');
            if ($client->testConnection()) {
                r2(U . 'plugin/genieacs_config', 's', 'Connection to ' . $found['name'] . ' successful');
            } else {
                r2(U . 'plugin/genieacs_config', 'e', 'Connection to ' . $found['name'] . ' failed');
            }
        } else {
            r2(U . 'plugin/genieacs_config', 'e', 'Host not found');
        }
    }

    if ($action == 'setactive') {
        $hostId = _get('id');
        $hosts = genieacs_get_hosts();
        foreach ($hosts as &$h) {
            $h['active'] = ($h['id'] == $hostId);
        }
        genieacs_save_hosts($hosts);
        r2(U . 'plugin/genieacs_config', 's', 'Active host changed');
    }

    if ($action == 'delete') {
        $hostId = _get('id');
        $hosts = genieacs_get_hosts();
        $newHosts = [];
        $deleted = false;
        foreach ($hosts as $h) {
            if ($h['id'] == $hostId) {
                $deleted = true;
            } else {
                $newHosts[] = $h;
            }
        }
        if ($deleted) {
            if (empty($newHosts)) {
                genieacs_save_hosts([]);
            } else {
                $hasActive = false;
                foreach ($newHosts as &$h) {
                    if (!empty($h['active'])) {
                        $hasActive = true;
                        break;
                    }
                }
                if (!$hasActive) {
                    $newHosts[0]['active'] = true;
                }
                genieacs_save_hosts($newHosts);
            }
            r2(U . 'plugin/genieacs_config', 's', 'Host deleted');
        } else {
            r2(U . 'plugin/genieacs_config', 'e', 'Host not found');
        }
    }

    $hosts = genieacs_get_hosts();
    $editHost = null;
    if ($action == 'edit') {
        $hostId = _get('id');
        foreach ($hosts as $h) {
            if ($h['id'] == $hostId) {
                $editHost = $h;
                break;
            }
        }
    }

    $ui->assign('_title', 'GenieACS Configuration');
    $ui->assign('_system_menu', 'settings');
    $ui->assign('_admin', $admin);
    $ui->assign('hosts', $hosts);
    $ui->assign('editHost', $editHost);
    $ui->assign('action', $action);
    $ui->display('genieacs_config.tpl');
}

function genieacs_format_uptime($seconds)
{
    if (!$seconds || !is_numeric($seconds)) {
        return '-';
    }
    $s = intval($seconds);
    $days = floor($s / 86400);
    $s %= 86400;
    $hours = floor($s / 3600);
    $s %= 3600;
    $mins = floor($s / 60);
    $secs = $s % 60;

    $parts = [];
    if ($days > 0) {
        $parts[] = "{$days}d";
    }
    if ($hours > 0) {
        $parts[] = "{$hours}h";
    }
    if ($mins > 0) {
        $parts[] = "{$mins}m";
    }
    $parts[] = "{$secs}s";

    return implode(' ', $parts);
}

function genieacs_extract_wlan_configs($device)
{
    $configs = [];

    for ($i = 1; $i <= 8; $i++) {
        $wlan = $device['InternetGatewayDevice']['LANDevice']['1']['WLANConfiguration'][$i] ?? null;
        if ($wlan) {
            $password = $wlan['KeyPassphrase']['_value'] ?? $wlan['PreSharedKey']['1']['KeyPassphrase']['_value'] ?? null;
            $configs[] = [
                'index' => $i,
                'ssid' => $wlan['SSID']['_value'] ?? null,
                'password' => $password,
                'enable' => $wlan['Enable']['_value'] ?? null,
                'channel' => $wlan['Channel']['_value'] ?? null,
                'beacon_type' => $wlan['BeaconType']['_value'] ?? null,
                'mac' => $wlan['BSSID']['_value'] ?? null,
                'standard' => $wlan['Standard']['_value'] ?? null,
                'max_bitrate' => $wlan['MaxBitRate']['_value'] ?? null,
                'connected_devices' => $wlan['AssociatedDeviceNumberOfEntries']['_value'] ?? $wlan['TotalAssociations']['_value'] ?? $wlan['X_CT-COM_AssociatedDeviceNumberOfEntries']['_value'] ?? null,
                'source' => 'tr098',
            ];
        }
    }

    for ($i = 1; $i <= 8; $i++) {
        $ssidEntry = $device['Device']['WiFi']['SSID'][$i] ?? null;
        if ($ssidEntry) {
            $ap = $device['Device']['WiFi']['AccessPoint'][$i] ?? null;
            $sec = $ap['Security'] ?? null;
            $radio = $device['Device']['WiFi']['Radio'][$i] ?? null;
            $password = $sec['KeyPassphrase']['_value'] ?? null;
            $configs[] = [
                'index' => $i,
                'ssid' => $ssidEntry['SSID']['_value'] ?? null,
                'password' => $password,
                'enable' => $ssidEntry['Enable']['_value'] ?? $ap['Enable']['_value'] ?? null,
                'channel' => $radio['Channel']['_value'] ?? null,
                'beacon_type' => $sec['ModeEnabled']['_value'] ?? null,
                'mac' => $ap['BSSID']['_value'] ?? null,
                'standard' => $radio['Standard']['_value'] ?? $radio['OperatingFrequencyBand']['_value'] ?? null,
                'max_bitrate' => $radio['SupportedFrequencies']['_value'] ?? null,
                'connected_devices' => $ap['AssociatedDeviceNumberOfEntries']['_value'] ?? $ap['TotalAssociations']['_value'] ?? null,
                'source' => 'tr181',
            ];
        }
    }

    return $configs;
}

function genieacs_dashboard()
{
    global $ui, $config, $admin;
    _admin();

    $hostId = _get('host_id');
    $client = genieacs_load_config($hostId);
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if ($hostId) {
            if ($h['id'] == $hostId) {
                $activeHost = $h;
                break;
            }
        } elseif (!empty($h['active'])) {
            $activeHost = $h;
            break;
        }
    }
    if (!$activeHost && !empty($hosts)) {
        $activeHost = $hosts[0];
    }

    $stats = ['total' => 0, 'online' => 0, 'offline' => 0];
    $devices = [];

    if ($client) {
        $result = $client->getDevices([], 500);
        if ($result['success'] && $result['data']) {
            $devices = $result['data'];
            $stats['total'] = count($devices);
            foreach ($devices as &$d) {
                $d['_extracted'] = genieacs_extract_device_info($d);
                $lastInform = $d['_lastInform'] ?? null;
                if ($lastInform) {
                    $ts = strtotime($lastInform);
                    if ($ts !== false && (time() - $ts) < 300) {
                        $stats['online']++;
                    } else {
                        $stats['offline']++;
                    }
                } else {
                    $stats['offline']++;
                }
            }
        }
    }

    $ui->assign('_title', 'GenieACS Dashboard');
    $ui->assign('_system_menu', 'plugin/genieacs_dashboard');
    $ui->assign('_admin', $admin);
    $recentDevices = array_slice($devices, 0, 10);
    $offlineDevices = [];
    foreach ($devices as &$d) {
        $lastInform = $d['_lastInform'] ?? null;
        $isOnline = $lastInform && (time() - strtotime($lastInform)) < 300;
        if (!$isOnline) {
            $offlineDevices[] = $d;
        }
    }
    $offlineDevices = array_slice($offlineDevices, 0, 20);

    $ui->assign('stats', $stats);
    $ui->assign('devices', $recentDevices);
    $ui->assign('offlineDevices', $offlineDevices);
    $ui->assign('hosts', $hosts);
    $ui->assign('activeHost', $activeHost);
    $ui->display('genieacs_dashboard.tpl');
}

function genieacs_devices()
{
    global $ui, $config, $admin;
    _admin();

    $hostId = _get('host_id');
    $client = genieacs_load_config($hostId);
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if ($hostId) {
            if ($h['id'] == $hostId) {
                $activeHost = $h;
                break;
            }
        } elseif (!empty($h['active'])) {
            $activeHost = $h;
            break;
        }
    }
    if (!$activeHost && !empty($hosts)) {
        $activeHost = $hosts[0];
    }

    $search = _get('search');
    $page = max(1, (int)_get('page', 1));
    $limit = 50;
    $skip = ($page - 1) * $limit;

    $query = [];
    if (!empty($search)) {
        $query = ['$or' => [
            ['_id' => ['$regex' => $search, '$options' => 'i']],
            ['_deviceId._SerialNumber' => ['$regex' => $search, '$options' => 'i']],
            ['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.Username._value' => ['$regex' => $search, '$options' => 'i']],
            ['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.2.WANPPPConnection.1.Username._value' => ['$regex' => $search, '$options' => 'i']],
        ]];
        $customers = ORM::for_table('tbl_customers')->where_like('fullname', "%{$search}%")->find_many();
        if ($customers) {
            foreach ($customers as $c) {
                $u = $c['pppoe_username'] ?: $c['username'];
                if (!empty($u)) {
                    $query['$or'][] = ['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.Username._value' => ['$regex' => '^' . preg_quote($u, '/') . '$', '$options' => 'i']];
                    $query['$or'][] = ['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.2.WANPPPConnection.1.Username._value' => ['$regex' => '^' . preg_quote($u, '/') . '$', '$options' => 'i']];
                }
            }
        }
    }

    $devices = [];
    $total = 0;
    if ($client) {
        $result = $client->getDevices($query, $limit, $skip);
        if ($result['success'] && $result['data']) {
            $devices = $result['data'];
            foreach ($devices as &$d) {
                $d['_extracted'] = genieacs_extract_device_info($d);
            }
        }
        $countResult = $client->getDevices($query, 0, 0);
        $total = ($countResult['success'] && $countResult['data']) ? count($countResult['data']) : 0;
    }

    $ui->assign('_title', 'GenieACS Devices');
    $ui->assign('_system_menu', 'plugin/genieacs_dashboard');
    $ui->assign('_admin', $admin);
    $ui->assign('devices', $devices);
    $ui->assign('total', $total);
    $ui->assign('page', $page);
    $ui->assign('limit', $limit);
    $ui->assign('search', $search);
    $ui->assign('hosts', $hosts);
    $ui->assign('activeHost', $activeHost);
    $ui->display('genieacs_devices.tpl');
}

function genieacs_device()
{
    global $ui, $config, $admin;
    _admin();

    $hostId = _get('host_id');
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device ID is required');
    }

    $client = genieacs_load_config($hostId);
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if ($hostId) {
            if ($h['id'] == $hostId) {
                $activeHost = $h;
                break;
            }
        } elseif (!empty($h['active'])) {
            $activeHost = $h;
            break;
        }
    }
    if (!$activeHost && !empty($hosts)) {
        $activeHost = $hosts[0];
    }

    $device = null;
    if ($client) {
        $result = $client->getDevice($deviceId);
        if ($result['success']) {
            $device = $result['data'];
        }
    }

    if (!$device) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device not found');
    }

    $uptimeRaw = $device['InternetGatewayDevice']['DeviceInfo']['UpTime']['_value'] ?? null;
    $uptime = genieacs_format_uptime($uptimeRaw);
    $wlanConfigs = genieacs_extract_wlan_configs($device);
    $temp = genieacs_extract_device_info($device);
    $temperature = $temp['temperature'];
    $temperatureRaw = $temp['temperature_raw'];
    $rxPower = $temp['rx_power'];
    $rxPowerRaw = $temp['rx_power_raw'];

    $ui->assign('_title', 'Device Detail - ' . $deviceId);
    $ui->assign('_system_menu', 'plugin/genieacs_dashboard');
    $ui->assign('_admin', $admin);
    $ui->assign('device', $device);
    $ui->assign('uptime', $uptime);
    $ui->assign('temperature', $temperature);
    $ui->assign('temperatureRaw', $temperatureRaw);
    $ui->assign('rxPower', $rxPower);
    $ui->assign('rxPowerRaw', $rxPowerRaw);
    $ui->assign('wlanConfigs', $wlanConfigs);
    $ui->assign('hosts', $hosts);
    $ui->assign('activeHost', $activeHost);
    $ui->display('genieacs_device.tpl');
}

function genieacs_reboot()
{
    _admin();
    $hostId = _get('host_id');
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device ID is required');
    }
    $client = genieacs_load_config($hostId);
    if (!$client) {
        r2(U . 'plugin/genieacs_devices', 'e', 'No GenieACS host configured');
    }
    $result = $client->rebootDevice($deviceId);
    $params = 'id=' . urlencode($deviceId);
    if ($hostId) {
        $params .= '&host_id=' . urlencode($hostId);
    }
    if ($result['success']) {
        r2(U . 'plugin/genieacs_device&' . $params, 's', 'Reboot command sent');
    } else {
        r2(U . 'plugin/genieacs_device&' . $params, 'e', 'Failed: ' . ($result['error'] ?? 'Unknown error'));
    }
}

function genieacs_summon()
{
    _admin();
    $hostId = _get('host_id');
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device ID is required');
    }
    $client = genieacs_load_config($hostId);
    if (!$client) {
        r2(U . 'plugin/genieacs_devices', 'e', 'No GenieACS host configured');
    }
    $result = $client->summonDevice($deviceId);
    $params = 'id=' . urlencode($deviceId);
    if ($hostId) {
        $params .= '&host_id=' . urlencode($hostId);
    }
    if ($result['success']) {
        r2(U . 'plugin/genieacs_device&' . $params, 's', 'Summon command sent');
    } else {
        r2(U . 'plugin/genieacs_device&' . $params, 'e', 'Failed: ' . ($result['error'] ?? 'Unknown error'));
    }
}

function genieacs_device_wan()
{
    global $ui, $config, $admin;
    _admin();

    $hostId = _get('host_id');
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device ID is required');
    }

    $client = genieacs_load_config($hostId);
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if ($hostId) {
            if ($h['id'] == $hostId) {
                $activeHost = $h;
                break;
            }
        } elseif (!empty($h['active'])) {
            $activeHost = $h;
            break;
        }
    }
    if (!$activeHost && !empty($hosts)) {
        $activeHost = $hosts[0];
    }

    $device = null;
    if ($client) {
        $result = $client->getDevice($deviceId);
        if ($result['success']) {
            $device = $result['data'];
        }
    }
    if (!$device) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device not found');
    }

    $saved = '';
    if (_post('save_wan')) {
        $connIndex = (int)_post('connection_index', 1);
        $connType = _post('connection_type', 'ppp');
        $params = [];

        $username = _post('username');
        $password = _post('password');
        $vlan = _post('vlan');
        $nat = _post('nat');

        $basePath = "InternetGatewayDevice.WANDevice.1.WANConnectionDevice.{$connIndex}";
        if ($connType === 'ppp') {
            $basePath .= '.WANPPPConnection.1';
        } else {
            $basePath .= '.WANIPConnection.1';
        }

        if (!empty($username)) {
            $params[] = [$basePath . '.Username', $username, 'xsd:string'];
        }
        if (!empty($password)) {
            $params[] = [$basePath . '.Password', $password, 'xsd:string'];
        }
        if (!empty($vlan)) {
            $params[] = ["InternetGatewayDevice.WANDevice.1.WANConnectionDevice.{$connIndex}.X_CT-COM_VLANID", (int)$vlan, 'xsd:unsignedInt'];
        }
        if ($nat !== '') {
            $params[] = [$basePath . '.NATEnabled', $nat === '1', 'xsd:boolean'];
        }

        if (!empty($params) && $client) {
            $res = $client->setParameterValues($deviceId, $params);
            if ($res['success']) {
                $saved = 'WAN configuration updated successfully';
            } else {
                $saved = 'Failed: ' . ($res['error'] ?? 'Unknown error');
            }
        } else {
            $saved = 'No parameters to update';
        }
    }

    $wanConnections = [];
    $usedIndexes = [];
    for ($i = 1; $i <= 8; $i++) {
        $ppp = $device['InternetGatewayDevice']['WANDevice']['1']['WANConnectionDevice'][$i]['WANPPPConnection']['1'] ?? null;
        $ip = $device['InternetGatewayDevice']['WANDevice']['1']['WANConnectionDevice'][$i]['WANIPConnection']['1'] ?? null;
        if ($ppp || $ip) {
            $conn = $ppp ?? $ip;
            $type = $ppp ? 'ppp' : 'ip';
            $wanConnections[] = [
                'index' => $i,
                'type' => $type,
                'username' => $ppp['Username']['_value'] ?? null,
                'password' => $ppp['Password']['_value'] ?? null,
                'external_ip' => $conn['ExternalIPAddress']['_value'] ?? null,
                'connection_type' => $conn['ConnectionType']['_value'] ?? null,
                'nat' => $conn['NATEnabled']['_value'] ?? null,
                'enable' => $conn['Enable']['_value'] ?? null,
                'gateway' => $conn['DefaultGateway']['_value'] ?? null,
                'subnet' => $conn['SubnetMask']['_value'] ?? null,
                'dns' => $conn['DNSServers']['_value'] ?? null,
            ];
            $usedIndexes[] = $i;
        }
    }

    $addMode = _get('add') == 1;
    $availIndex = null;
    if ($addMode) {
        for ($i = 1; $i <= 8; $i++) {
            if (!in_array($i, $usedIndexes)) {
                $availIndex = $i;
                break;
            }
        }
    }

    $ui->assign('_title', "WAN Configuration - {$deviceId}");
    $ui->assign('_system_menu', 'plugin/genieacs_dashboard');
    $ui->assign('_admin', $admin);
    $ui->assign('device', $device);
    $ui->assign('deviceId', $deviceId);
    $ui->assign('activeHost', $activeHost);
    $ui->assign('wanConnections', $wanConnections);
    $ui->assign('saved', $saved);
    $ui->assign('addMode', $addMode);
    $ui->assign('availIndex', $availIndex);
    $ui->display('genieacs_device_wan.tpl');
}

function genieacs_device_wlan()
{
    global $ui, $config, $admin;
    _admin();

    $hostId = _get('host_id');
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device ID is required');
    }

    $client = genieacs_load_config($hostId);
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if ($hostId) {
            if ($h['id'] == $hostId) {
                $activeHost = $h;
                break;
            }
        } elseif (!empty($h['active'])) {
            $activeHost = $h;
            break;
        }
    }
    if (!$activeHost && !empty($hosts)) {
        $activeHost = $hosts[0];
    }

    $device = null;
    if ($client) {
        $result = $client->getDevice($deviceId);
        if ($result['success']) {
            $device = $result['data'];
        }
    }
    if (!$device) {
        r2(U . 'plugin/genieacs_devices', 'e', 'Device not found');
    }

    $saved = '';
    if (_post('save_wlan')) {
        $wlanIndex = (int)_post('wlan_index', 1);
        $ssid = _post('ssid');
        $password = _post('password');
        $security = _post('security_mode', 'WPA2PSK');

        $params = [];

        $ssidPath = "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.SSID";
        $params[] = [$ssidPath, $ssid, 'xsd:string'];

        $beaconTypeMap = [
            'WPA2PSK' => '11i',
            'WPAPSK' => 'WPA',
            'WPA2PSKWPAPSK' => 'WPAand11i',
            'None' => 'Basic',
        ];
        $beaconType = $beaconTypeMap[$security] ?? '11i';
        $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.BeaconType", $beaconType, 'xsd:string'];

        if ($security !== 'None' && !empty($password)) {
            $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.KeyPassphrase", $password, 'xsd:string'];
            $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.WPAAuthenticationMode", 'PSKAuthentication', 'xsd:string'];
            $encryptionMode = ($security === 'WPA2PSK' || $security === 'WPA2PSKWPAPSK') ? 'AESEncryption' : 'TKIPEncryption';
            $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.WPAEncryptionModes", $encryptionMode, 'xsd:string'];
        }

        if ($client) {
            $res = $client->setParameterValues($deviceId, $params, 10000);
            if ($res['success']) {
                $saved = 'WLAN configuration updated successfully';
            } else {
                $saved = 'Failed: ' . ($res['error'] ?? 'Unknown error');
            }
        }
    }

    $wlanConfigs = genieacs_extract_wlan_configs($device);

    $ui->assign('_title', "WLAN Configuration - {$deviceId}");
    $ui->assign('_system_menu', 'plugin/genieacs_dashboard');
    $ui->assign('_admin', $admin);
    $ui->assign('device', $device);
    $ui->assign('deviceId', $deviceId);
    $ui->assign('activeHost', $activeHost);
    $ui->assign('wlanConfigs', $wlanConfigs);
    $ui->assign('saved', $saved);
    $ui->display('genieacs_device_wlan.tpl');
}

function genieacs_customer_dashboard()
{
    global $ui;
    _auth();
    $customer = User::_info();
    if (!$customer) {
        r2(getUrl('home'), 'e', 'Customer not found');
    }

    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if (!empty($h['active'])) {
            $activeHost = $h;
            break;
        }
    }
    if (!$activeHost) {
        $activeHost = $hosts[0] ?? null;
    }
    if (!$activeHost) {
        $ui->assign('_title', Lang::T('GenieACS'));
        $ui->assign('error', Lang::T('No GenieACS host configured.'));
        $ui->display('genieacs_customer.tpl');
        return;
    }

    $client = new GenieACSClient($activeHost['host'], $activeHost['port'] ?? 7557, $activeHost['username'] ?? '', $activeHost['password'] ?? '');

    $search = $customer['pppoe_username'] ?: $customer['username'];
    $device = null;
    $deviceInfo = null;
    $wlanConfigs = [];

    if ($search) {
        $regex = ['$regex' => '^' . preg_quote($search, '/') . '$', '$options' => 'i'];
        $query = ['$or' => [
            ['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.1.Username._value' => $regex],
            ['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.2.WANPPPConnection.1.Username._value' => $regex],
            ['_deviceId._SerialNumber' => $regex],
            ['_id' => $regex],
        ]];
        $result = $client->getDevices($query, 1, 0);
        if ($result['success'] && !empty($result['data'])) {
            $device = $result['data'][0];
        }
    }

    if ($device) {
        $deviceInfo = genieacs_extract_device_info($device);
        $wlanConfigs = genieacs_extract_wlan_configs($device);
    }

    $online = false;
    if ($device && isset($device['_lastInform'])) {
        $online = (time() - strtotime($device['_lastInform'])) < 300;
    }

    $ui->assign('_title', Lang::T('GenieACS - My Device'));
    $ui->assign('device', $device);
    $ui->assign('deviceInfo', $deviceInfo);
    $ui->assign('wlanConfigs', $wlanConfigs);
    $ui->assign('online', $online);
    $ui->assign('customer', $customer);
    $ui->display('genieacs_customer.tpl');
}

function genieacs_customer_reboot()
{
    _auth();
    $customer = User::_info();
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 'e', 'Device ID is required');
    }
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if (!empty($h['active'])) { $activeHost = $h; break; }
    }
    if (!$activeHost) { $activeHost = $hosts[0] ?? null; }
    if (!$activeHost) {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 'e', 'No GenieACS host configured');
    }
    $client = new GenieACSClient($activeHost['host'], $activeHost['port'] ?? 7557, $activeHost['username'] ?? '', $activeHost['password'] ?? '');
    $result = $client->rebootDevice($deviceId);
    if ($result['success']) {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 's', 'Reboot command sent');
    } else {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 'e', 'Failed: ' . ($result['error'] ?? 'Unknown error'));
    }
}

function genieacs_customer_wlan_edit()
{
    global $ui;
    _auth();
    $customer = User::_info();
    $deviceId = _get('id');
    if (empty($deviceId)) {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 'e', 'Device ID is required');
    }
    $hosts = genieacs_get_hosts();
    $activeHost = null;
    foreach ($hosts as $h) {
        if (!empty($h['active'])) { $activeHost = $h; break; }
    }
    if (!$activeHost) { $activeHost = $hosts[0] ?? null; }
    if (!$activeHost) {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 'e', 'No GenieACS host configured');
    }
    $client = new GenieACSClient($activeHost['host'], $activeHost['port'] ?? 7557, $activeHost['username'] ?? '', $activeHost['password'] ?? '');
    $result = $client->getDevice($deviceId);
    if (!$result['success']) {
        r2(getUrl('plugin/genieacs_customer_dashboard'), 'e', 'Device not found');
    }
    $device = $result['data'];
    $saved = '';
    if (_post('save_wlan')) {
        $wlanIndex = (int)_post('wlan_index', 1);
        $ssid = _post('ssid');
        $password = _post('password');
        $security = _post('security_mode', 'WPA2PSK');
        $params = [];
        $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.SSID", $ssid, 'xsd:string'];
        $beaconTypeMap = ['WPA2PSK' => '11i', 'WPAPSK' => 'WPA', 'WPA2PSKWPAPSK' => 'WPAand11i', 'None' => 'Basic'];
        $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.BeaconType", $beaconTypeMap[$security] ?? '11i', 'xsd:string'];
        if ($security !== 'None' && !empty($password)) {
            $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.KeyPassphrase", $password, 'xsd:string'];
            $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.WPAAuthenticationMode", 'PSKAuthentication', 'xsd:string'];
            $encryptionMode = ($security === 'WPA2PSK' || $security === 'WPA2PSKWPAPSK') ? 'AESEncryption' : 'TKIPEncryption';
            $params[] = ["InternetGatewayDevice.LANDevice.1.WLANConfiguration.{$wlanIndex}.WPAEncryptionModes", $encryptionMode, 'xsd:string'];
        }
        $res = $client->setParameterValues($deviceId, $params, 10000);
        if ($res['success']) {
            $saved = 'WLAN configuration updated successfully';
        } else {
            $saved = 'Failed: ' . ($res['error'] ?? 'Unknown error');
        }
    }
    $wlanConfigs = genieacs_extract_wlan_configs($device);
    $ui->assign('_title', Lang::T('WLAN Configuration'));
    $ui->assign('device', $device);
    $ui->assign('deviceId', $deviceId);
    $ui->assign('wlanConfigs', $wlanConfigs);
    $ui->assign('saved', $saved);
    $ui->display('genieacs_customer_wlan.tpl');
}
