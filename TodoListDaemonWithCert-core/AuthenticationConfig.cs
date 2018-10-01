/*
 The MIT License (MIT)

Copyright (c) 2015 Microsoft Corporation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */ 
 
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;

namespace TodoListDaemonWithCert
{
    public class AuthenticationConfig
    {
        /// <summary>
        /// instance of Azure, for example public Azure or a Sovereign cloud (Azure China, Germany, US government, etc ...)
        /// </summary>
        public string AADInstance { get; set; }

        /// <summary>
        /// The Tenant is the name of the Azure AD tenant in which this application is registered.
        /// </summary>
        public string Tenant { get; set; }

        /// <summary>
        /// Guid used by the application to uniquely identify itself to Azure AD
        /// </summary>
        public string ClientId { get; set; }

        /// <summary>
        /// App ID URI For the Todo list service.
        /// </summary>
        public string TodoListResourceId { get; set; }

        /// <summary>
        /// Url to the Todo list service
        /// </summary>
        public string TodoListBaseAddress { get; set; }

        /// <summary>
        /// subject name of the certificate used to authenticate this application to Azure AD using the 
        /// Certificate client credentials
        /// </summary>
        public string CertName { get; set; }

        /// <summary>
        /// Sign-in URL of the tenant.
        /// </summary>
        public string Authority
        {
            get
            {
                return String.Format(CultureInfo.InvariantCulture, AADInstance, Tenant);
            }
        }

        /// <summary>
        /// Reads the configuration from a json file
        /// </summary>
        /// <param name="file"></param>
        /// <returns></returns>
        public static AuthenticationConfig ReadFromJsonFile(string file)
        {
            IConfigurationRoot Configuration;

            var builder = new ConfigurationBuilder()
             .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile(file);

            Configuration = builder.Build();
            return Configuration.Get<AuthenticationConfig>();
        }
    }



}

