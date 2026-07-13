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
    public class ZnackaController : BaseCRUDController<Znacka, ZnackaSearchObject, ZnackaInsertRequest, ZnackaUpdateRequest>
    {
        public ZnackaController(ILogger<BaseController<Znacka, ZnackaSearchObject>> logger, IZnackaService service) : base(logger, service)
        {

        }
        // [Authorize(Roles = "Administrator")]
        public override Task<Znacka> Insert([FromBody] ZnackaInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<Znacka> Update(int id, [FromBody] ZnackaUpdateRequest update)
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
