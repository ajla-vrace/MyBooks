using Microsoft.AspNetCore.Mvc;

namespace MyBooks.Controllers
{
    public class ZnackaController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
