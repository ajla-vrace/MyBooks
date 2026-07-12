using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IZnackaService : ICRUDService<Model.Znacka, Model.SearchObject.ZnackaSearchObject, Model.Requests.ZnackaInsertRequest, Model.Requests.ZnackaUpdateRequest>
    {
       // Task<StatistikaResponse> GetStatistika();
    }
}
