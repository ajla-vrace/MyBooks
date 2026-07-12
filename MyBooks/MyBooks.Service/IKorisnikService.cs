using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IKorisnikService : ICRUDService<Model.Korisnik, Model.SearchObject.KorisnikSearchObject, Model.Requests.KorisnikInsertRequest, Model.Requests.KorisnikUpdateRequest>
    {
        // Task<StatistikaResponse> GetStatistika();
        Task<Model.Korisnik> Login(string email, string password);
    }
}
