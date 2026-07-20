using MyBooks.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IKorisnikZnackaService : ICRUDService<Model.KorisnikZnacka, Model.SearchObject.KorisnikZnackaSearchObject, Model.Requests.KorisnikZnackaInsertRequest, Model.Requests.KorisnikZnackaUpdateRequest>
    {
        Task ProvjeriZnacke(int korisnikId);
        Task<Znacka?> GetSljedecaZnacka(int idKorisnik);
    }
}
