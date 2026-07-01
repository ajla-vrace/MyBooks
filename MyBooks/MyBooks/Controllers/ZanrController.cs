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
    public class ZanrController : BaseCRUDController<Zanr, ZanrSearchObject, ZanrInsertRequest, ZanrUpdateRequest>
    {
        public ZanrController(ILogger<BaseController<Zanr, ZanrSearchObject>> logger, IZanrService service) : base(logger, service)
        {

        }
        // [Authorize(Roles = "Administrator")]
        public override Task<Zanr> Insert([FromBody] ZanrInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<Zanr> Update(int id, [FromBody] ZanrUpdateRequest update)
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
