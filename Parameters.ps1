   # Variables for the registration of the AAD application for the Web API Service
    $serviceAadAppName = "TodoListService-Core"
    $serviceHomePage = "https://localhost:44341"
    $serviceAppIdURI = "https://$tenantName/$serviceAadAppName"

    # Variables for the registration of the AAD application for the Daemon app
    $daemonAadAppName = "TodoListDaemonWithCertCore"
    $daemonHomePage = "https://$daemonAadAppName"
    $daemonAppIdURI = "https://$daemonAadAppName"
    $certificateName = "CN=TodoListDaemonWithCert"
