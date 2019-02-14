using KubeUI.Models;
using Microsoft.AspNetCore.Mvc;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace KubeUI.Controllers
{
    public class HomeController : Controller
    {

        public IActionResult Index()
        {
            try
            {

                string Endpoint = Environment.GetEnvironmentVariable("KubeApiUrl");
                RestClient restClient = new RestClient();
                restClient.BaseUrl = new Uri("http://kubeapi/api/Values");
                var request = new RestRequest(Method.GET);

                var response = restClient.Execute<List<string>>(request);

                var result = response.Content;

                ViewBag.List = result;


            }
            catch (Exception ex)
            {
                ViewBag.List = ex.Message;
            }
            return View();

        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
