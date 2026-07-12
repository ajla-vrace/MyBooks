using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using System.Security.Cryptography;
using System.Text;

namespace MyBooks.Service
{
    public class KorisnikService : BaseCRUDService<
        Model.Korisnik,
        Database.Korisnik,
        KorisnikSearchObject,
        KorisnikInsertRequest,
        KorisnikUpdateRequest>, IKorisnikService
    {

        public KorisnikService(
            MyBooksContext context,
            IMapper mapper
        ) : base(context, mapper)
        {

        }



        // ============================
        // GENERATE SALT
        // ============================

        public static byte[] GenerateSalt()
        {
            byte[] salt = new byte[16];

            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            return salt;
        }



        // ============================
        // GENERATE HASH
        // ============================

        public static byte[] GenerateHash(
            byte[] salt,
            string password)
        {

            byte[] passwordBytes =
                Encoding.UTF8.GetBytes(password);


            byte[] combined =
                new byte[salt.Length + passwordBytes.Length];


            Buffer.BlockCopy(
                salt,
                0,
                combined,
                0,
                salt.Length
            );


            Buffer.BlockCopy(
                passwordBytes,
                0,
                combined,
                salt.Length,
                passwordBytes.Length
            );


            using (SHA256 sha = SHA256.Create())
            {
                return sha.ComputeHash(combined);
            }
        }





        // ============================
        // INSERT
        // ============================

        public override async Task<Model.Korisnik> Insert(
            KorisnikInsertRequest insert)
        {

            bool postoji =
                await _context.Korisniks
                .AnyAsync(x => x.Email == insert.Email);


            if (postoji)
            {
                throw new Exception(
                    "Korisnik sa ovim emailom već postoji."
                );
            }



            var entity =
                _mapper.Map<Database.Korisnik>(insert);



            entity.DatumRegistracije =
                DateTime.Now;



            entity.LozinkaSalt =
                GenerateSalt();



            entity.LozinkaHash =
                GenerateHash(
                    entity.LozinkaSalt,
                    insert.Lozinka
                );



            _context.Korisniks.Add(entity);


            await _context.SaveChangesAsync();



            return _mapper.Map<Model.Korisnik>(entity);
        }





        // ============================
        // UPDATE
        // ============================

        public override async Task<Model.Korisnik> Update(
            int id,
            KorisnikUpdateRequest update)
        {

            var entity =
                await _context.Korisniks
                .FindAsync(id);


            if (entity == null)
            {
                throw new Exception(
                    "Korisnik nije pronađen."
                );
            }



            _mapper.Map(update, entity);



            await _context.SaveChangesAsync();



            return _mapper.Map<Model.Korisnik>(entity);
        }





        // ============================
        // LOGIN
        // ============================

        public async Task<Model.Korisnik?> Login(
            string email,
            string lozinka)
        {


            var entity =
                await _context.Korisniks
                .FirstOrDefaultAsync(
                    x => x.Email == email
                );



            if (entity == null)
            {
                return null;
            }



            byte[] hash =
                GenerateHash(
                    entity.LozinkaSalt,
                    lozinka
                );



            if (!hash.SequenceEqual(entity.LozinkaHash))
            {
                return null;
            }



            return _mapper.Map<Model.Korisnik>(entity);
        }





        // ============================
        // FILTER
        // ============================

        public override IQueryable<Database.Korisnik> AddFilter(
            IQueryable<Database.Korisnik> query,
            KorisnikSearchObject? search = null)
        {

            var filtered =
                base.AddFilter(query, search);



            if (!string.IsNullOrWhiteSpace(search?.Ime))
            {
                filtered =
                    filtered.Where(
                        x => x.Ime.Contains(search.Ime)
                    );
            }



            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                filtered =
                    filtered.Where(
                        x => x.Email.Contains(search.Email)
                    );
            }



            return filtered;
        }

    }
}