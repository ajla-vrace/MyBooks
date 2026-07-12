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
    public class KnjigaController : BaseCRUDController<Knjiga, KnjigaSearchObject, KnjigaInsertRequest, KnjigaUpdateRequest>
    {
        private readonly IKnjigaService _service;
        public KnjigaController(ILogger<BaseController<Knjiga, KnjigaSearchObject>> logger, IKnjigaService service) : base(logger, service)
        {
            _service = service;
        }
       // [Authorize(Roles = "Administrator")]
        public override Task<Knjiga> Insert([FromBody] KnjigaInsertRequest insert)
        {
            return base.Insert(insert);
        }
        // Update metoda
       // [Authorize(Roles = "Administrator")]
        public override Task<Knjiga> Update(int id, [FromBody] KnjigaUpdateRequest update)
        {
            return base.Update(id, update);
        }

        // Delete metoda
        //[Authorize(Roles = "Administrator")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }
        [HttpGet("statistika")]
        public async Task<StatistikaResponse> GetStatistika(int korisnikId)
        {
            return await _service.GetStatistika(korisnikId);
        }
    }
}
