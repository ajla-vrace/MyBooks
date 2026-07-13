using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using MyBooks.Service;

namespace MyBooks.Service
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {

            //<Database.Knjiga, Model.Knjiga>();
            CreateMap<Database.Knjiga, Model.Knjiga>()
    .ForMember(dest => dest.Zanrovi,
        opt => opt.MapFrom(src =>
            src.KnjigaZanrs.Select(x => x.IdZanrNavigation)
        ));
            CreateMap<Model.Requests.KnjigaInsertRequest, Database.Knjiga>();
            CreateMap<Model.Requests.KnjigaUpdateRequest, Database.Knjiga>();

            CreateMap<Database.Zanr, Model.Zanr>();
            CreateMap<Model.Requests.ZanrInsertRequest, Database.Zanr>();
            CreateMap<Model.Requests.ZanrUpdateRequest, Database.Zanr>();

            CreateMap<Database.Citat, Model.Citat>();
            CreateMap<Model.Requests.CitatInsertRequest, Database.Citat>();
            CreateMap<Model.Requests.CitatUpdateRequest, Database.Citat>();

            CreateMap<Database.WishKnjiga, Model.WishKnjiga>();
            CreateMap<Model.Requests.WishKnjigaInsertRequest, Database.WishKnjiga>();
            CreateMap<Model.Requests.WishKnjigaUpdateRequest, Database.WishKnjiga>();

            CreateMap<Database.KnjigaZanr, Model.KnjigaZanr>();
            CreateMap<Model.Requests.KnjigaZanrInsertRequest, Database.KnjigaZanr>();
            CreateMap<Model.Requests.KnjigaZanrUpdateRequest, Database.KnjigaZanr>();

            CreateMap<Database.Korisnik, Model.Korisnik>();
            CreateMap<Model.Requests.KorisnikInsertRequest, Database.Korisnik>();
            CreateMap<Model.Requests.KorisnikUpdateRequest, Database.Korisnik>();

            CreateMap<Database.Znacka, Model.Znacka>();
            CreateMap<Model.Requests.ZnackaInsertRequest, Database.Znacka>();
            CreateMap<Model.Requests.ZnackaUpdateRequest, Database.Znacka>();

            CreateMap<Database.KorisnikZnacka, Model.KorisnikZnacka>();
            CreateMap<Model.Requests.KorisnikZnackaInsertRequest, Database.KorisnikZnacka>();
            CreateMap<Model.Requests.KorisnikZnackaUpdateRequest, Database.KorisnikZnacka>();



        }
    }

   
}
