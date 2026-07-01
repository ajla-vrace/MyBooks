using MyBooks.Model.Requests;
using MyBooks.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IKnjigaService : ICRUDService<Model.Knjiga, Model.SearchObject.KnjigaSearchObject, Model.Requests.KnjigaInsertRequest, Model.Requests.KnjigaUpdateRequest>
    {
        Task<StatistikaResponse> GetStatistika();
    }
}
