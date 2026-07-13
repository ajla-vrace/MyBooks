using MyBooks.Model;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using MyBooks.Controllers;

namespace eSpa.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikZnackaController : BaseCRUDController<KorisnikZnacka, KorisnikZnackaSearchObject, KorisnikZnackaInsertRequest, KorisnikZnackaUpdateRequest>
    {
        public KorisnikZnackaController(ILogger<BaseController<KorisnikZnacka, KorisnikZnackaSearchObject>> logger, IKorisnikZnackaService service) : base(logger, service)
        {

        }
        // [Authorize(Roles = "Administrator")]
        public override Task<KorisnikZnacka> Insert([FromBody] KorisnikZnackaInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<KorisnikZnacka> Update(int id, [FromBody] KorisnikZnackaUpdateRequest update)
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
