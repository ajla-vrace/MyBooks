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
    public class CitatController : BaseCRUDController<Citat, CitatSearchObject, CitatInsertRequest, CitatUpdateRequest>
    {
        public CitatController(ILogger<BaseController<Citat, CitatSearchObject>> logger, ICitatService service) : base(logger, service)
        {

        }
        // [Authorize(Roles = "Administrator")]
        public override Task<Citat> Insert([FromBody] CitatInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<Citat> Update(int id, [FromBody] CitatUpdateRequest update)
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
