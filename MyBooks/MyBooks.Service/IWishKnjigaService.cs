using MyBooks.Model.Requests;
using MyBooks.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IWishKnjigaService : ICRUDService<Model.WishKnjiga, Model.SearchObject.WishKnjigaSearchObject, Model.Requests.WishKnjigaInsertRequest, Model.Requests.WishKnjigaUpdateRequest>
    {
        Task<Model.WishKnjiga?> GetRandom();
    }
}
