function main(config) {
  // 1. DNS 配置优化
  if (!config.dns) config.dns = {};
  if (!config.dns['nameserver-policy']) config.dns['nameserver-policy'] = {};
  
  const dnsPolicies = {
    "geosite:microsoft@cn": "223.5.5.5", // 微软中国区走国内解析
    "domain:live.com,microsoftonline.com,login.microsoftonline.com,login.live.com": "8.8.8.8" // 登录接口走海外解析避开污染
  };
  Object.assign(config.dns['nameserver-policy'], dnsPolicies);

  // 2. 精准直连规则
  const myRules = [
    "GEOIP,LAN,DIRECT,no-resolve",       // 局域网直连 (Phone Link 必需)
    
    // 微软登录关键域名 (仅直连登录验证部分)
    "DOMAIN-SUFFIX,login.microsoftonline.com,DIRECT",
    "DOMAIN-SUFFIX,login.live.com,DIRECT",
    "DOMAIN-SUFFIX,logincdn.msauth.net,DIRECT",
    "DOMAIN-SUFFIX,account.live.com,DIRECT",
    "DOMAIN-SUFFIX,account.microsoft.com,DIRECT",
    
    // 如果你发现 Outlook 网页版打不开，再取消下面这行的注释
    // "DOMAIN-SUFFIX,outlook.com,DIRECT",

    "GEOIP,CN,DIRECT"                    // 国内 IP 直连
  ];

  // 合并规则：确保自定义规则在最上方
  config.rules = [...myRules, ...config.rules];

  return config;
}