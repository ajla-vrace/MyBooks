using MyBooks.Model.Requests;
using MyBooks.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IKnjigaZanrService : ICRUDService<Model.KnjigaZanr, Model.SearchObject.KnjigaZanrSearchObject, Model.Requests.KnjigaZanrInsertRequest, Model.Requests.KnjigaZanrUpdateRequest>
    {

    }
}
