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
    public class WishKnjigaController : BaseCRUDController<WishKnjiga, WishKnjigaSearchObject, WishKnjigaInsertRequest, WishKnjigaUpdateRequest>
    {
        private readonly IWishKnjigaService _service;
        public WishKnjigaController(ILogger<BaseController<WishKnjiga, WishKnjigaSearchObject>> logger, IWishKnjigaService service) : base(logger, service)
        {
            _service = service;
        }
        // [Authorize(Roles = "Administrator")]
        public override Task<WishKnjiga> Insert([FromBody] WishKnjigaInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
        // [Authorize(Roles = "Administrator")]
        public override Task<WishKnjiga> Update(int id, [FromBody] WishKnjigaUpdateRequest update)
        {
            return base.Update(id, update);
        }

        // Delete metoda
        //[Authorize(Roles = "Administrator")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }
        [HttpGet("random")]
        public async Task<WishKnjiga?> GetRandom(int korisnikId)
        {
            return await _service.GetRandom(korisnikId);
        }

    }
}
