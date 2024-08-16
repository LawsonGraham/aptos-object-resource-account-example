module package_test::package_test {
    use std::signer;

    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::account;

    const ERR_UNAUTHORIZED: u64 = 1;

    struct ResourceAccountObjectStore has key, store {
        resource_object: address
    }

    struct ResourceAccountObject has key, store {
        extend_ref: ExtendRef
    }

    fun init_module(deployer: &signer) {
        let resource_object_cref = object::create_named_object(deployer, vector<u8>[]);
        let resource_obj_signer = object::generate_signer(&resource_object_cref);
        let resource_obj_extend_ref = object::generate_extend_ref(&resource_object_cref);
        
        move_to(&resource_obj_signer, ResourceAccountObject {
            extend_ref: resource_obj_extend_ref,
        });

        move_to(deployer, ResourceAccountObjectStore {
            resource_object: object::address_from_constructor_ref(&resource_object_cref),
        });
    }

    public fun resoure_account_signer(): signer acquires ResourceAccountObjectStore, ResourceAccountObject {
        let resource_obj_addr = borrow_global<ResourceAccountObjectStore>(@package_test).resource_object;
        let resource_obj = borrow_global<ResourceAccountObject>(resource_obj_addr);
        object::generate_signer_for_extending(&resource_obj.extend_ref)
    }

    #[test]
    fun test_resource_account_signer() acquires ResourceAccountObjectStore, ResourceAccountObject {
        let package_signer = account::create_account_for_test(@package_test);
        init_module(&package_signer);
        let resource_obj_signer = resoure_account_signer();

        assert!(signer::address_of(&resource_obj_signer) == borrow_global_mut<ResourceAccountObjectStore>(@package_test).resource_object, 0);
    }
}
