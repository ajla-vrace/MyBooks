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
    public class KnjigaZanrController : BaseCRUDController<KnjigaZanr, KnjigaZanrSearchObject, KnjigaZanrInsertRequest, KnjigaZanrUpdateRequest>
    {
        public KnjigaZanrController(ILogger<BaseController<KnjigaZanr, KnjigaZanrSearchObject>> logger, IKnjigaZanrService service) : base(logger, service)
        {

        }
        // [Authorize(Roles = "Administrator")]
        public override Task<KnjigaZanr> Insert([FromBody] KnjigaZanrInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<KnjigaZanr> Update(int id, [FromBody] KnjigaZanrUpdateRequest update)
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
