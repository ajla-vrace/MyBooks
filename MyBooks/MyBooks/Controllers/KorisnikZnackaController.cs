using Microsoft.AspNetCore.Mvc;

namespace MyBooks.Controllers
{
    public class KorisnikZnackaController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
