using Microsoft.AspNetCore.Mvc;
using MyBooks.Model;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service;

namespace MyBooks.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : BaseCRUDController<Korisnik, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        private readonly IKorisnikService _service;
        public KorisnikController(ILogger<BaseController<Korisnik, KorisnikSearchObject>> logger, IKorisnikService service) : base(logger, service)
        {
            _service = service;
        }
        // [Authorize(Roles = "Administrator")]
        public override Task<Korisnik> Insert([FromBody] KorisnikInsertRequest insert)
        {
            return base.Insert(insert);
        }


        [HttpPost("login")]
        public async Task<Korisnik?> Login(LoginRequest request)
        {
            return await _service.Login(
                request.Email,
                request.Lozinka
            );
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<Korisnik> Update(int id, [FromBody] KorisnikUpdateRequest update)
        {
            return base.Update(id, update);
        }

        // Delete metoda
        //[Authorize(Roles = "Administrator")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }
       
    }
}
